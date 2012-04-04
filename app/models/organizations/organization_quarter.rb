# An Organization can be active for any specific Quarter. This object models this relationship. A record in this table implies that an Organization is active for the specified Quarter.
class OrganizationQuarter < ActiveRecord::Base
  stampable
  belongs_to :organization
  belongs_to :quarter
  belongs_to :staff_contact_user, :class_name => "User", :foreign_key => "staff_contact_user_id", :include => :person
  has_many :positions, :class_name => "ServiceLearningPosition", :dependent => :destroy do
    def in_progress; find(:all, :conditions => { :in_progress => true }); end
    def pending; find(:all, :conditions => "(approved IS NULL OR approved = 0) && (in_progress IS NULL OR in_progress = 0)"); end
    def approved; find(:all, :conditions => { :approved => true }); end
  end
  # has_many :pipeline_positions, :class_name => "PipelinePosition", :dependent => :destroy
  has_many :placements, :through => :positions, :source => :placements do
    def filled; find(:all, :conditions => 'person_id IS NOT NULL'); end; end
  # has_many :pipeline_placements, :through => :pipeline_positions, :source => :placements do
  #   def filled; find(:all, :conditions => 'person_id IS NOT NULL'); end; end
  has_many :statuses, :class_name => "OrganizationQuarterStatus", :dependent => :destroy
  has_many :potential_course_organization_match_for_quarters, :dependent => :destroy
  has_many :potential_courses, :through => :potential_course_organization_match_for_quarters, :source => :service_learning_course
  
  has_many :related_organization_quarters, :class_name => "OrganizationQuarter", 
           :finder_sql => %q( SELECT * FROM organization_quarters oq WHERE oq.organization_id = #{organization_id} AND oq.quarter_id = #{quarter_id} AND oq.unit_id != #{unit_id} )
  
  belongs_to :unit, :class_name => "Unit"
  
  acts_as_soft_deletable
  
  validates_presence_of :organization_id
  validates_presence_of :quarter_id
  validates_associated :potential_course_organization_match_for_quarters
  validates_uniqueness_of :organization_id, :scope => [:quarter_id, :unit_id]
  
  delegate :title, :to => :quarter
  delegate :name, :to => :organization

  MID_QUARTER_EMAIL_TEMPLATES = {
		'Invite and Evaluate'	=> EmailTemplate.find_by_name('service learning mid quarter invite and eval'), 
		'Invite only' 		  	=> EmailTemplate.find_by_name('service learning mid quarter invite only'),
		'Evaluate only' 	  	=> EmailTemplate.find_by_name('service learning mid quarter eval only')
	}
  
  def <=>(o)
    quarter <=> o.quarter
  end
  
  def unit_name
    unit.try(:name)
  end
  
  # Return organization quarter's existing units abbreviation without self
  def other_units(unit, quarter, org)
    OrganizationQuarter.find_all_by_organization_id_and_quarter_id(org, quarter).reject{|oq| oq.unit_id == unit.id}.collect(&:unit).collect(&:abbreviation)
  end
  
  # The current status type of this organization for the current quarter. If none is defined, create a new status with the
  # first default, which is "Needs Contact".
  def status
    s = statuses.find(:first, :order => "updated_at DESC")
    if s.nil?
      s = statuses.create :organization_quarter_status_type_id => OrganizationQuarterStatusType.find_or_create_by_title("Needs Contact").id
      s.type.sequence = 0; s.type.save;
    end
    s
  end
  
  # Sets a new status for this OrganizationQuarter and, if the new status's abbreviation is "inactive", then also
  # mark the organization as inactive.
  def status=(new_status_type_id)
    new_status = statuses.create :organization_quarter_status_type_id => new_status_type_id
    organization.mark_inactive(quarter.next) if new_status.type.abbreviation == "inactive"
    return new_status
  end

  # Returns true if this OrganizationQuarter has a status with an "inactive" abbreviation.
  def inactive_status?
    status.type.abbreviation == 'inactive' rescue false
  end

  # Returns the listing of students currently placed with this organization (TODO: This should probably be turned into a real association)
  def students
    placements.collect{|p| p.person }.compact.uniq
  end
  def pipeline_students
    pipeline_placements.collect{|p| p.person }.compact.uniq
  end

  def courses
    placements.collect{|p| p.course }.compact.uniq
  end
  
  attr_accessor :potential_course_match
  
  def potential_course_match=(new_potential_course_id)
    potential_course_organization_match_for_quarters.create :service_learning_course_id => new_potential_course_id
  end

  def delete_potential_course_match(existing_potential_course_id)
    potential_course_organization_match_for_quarters.find_by_service_learning_course_id(existing_potential_course_id).destroy
  end

  # Toggles the +allow_position_edits+ attribute for this organization for the current quarter. When set to true, community 
  # partners are allowed to make changes to the position details for the current quarter.
  def toggle_allow_position_edits
    update_attribute :allow_position_edits, !allow_position_edits?
    allow_position_edits?
  end

  # Toggles the +allow_evals+ attribute for this organization for the current quarter. When set to true, community partners are 
  # allowed to submit evaluations for student volunteers.
  def toggle_allow_evals
    update_attribute :allow_evals, !allow_evals?
    allow_evals?
  end

  # Returns true if the only filled placements for this quarter are self-placements
  def self_placements_only?
    count = 0
    placements.filled.each{|p| count += 1 if p.position.self_placement? }
    count == placements.filled.size
  end

  # Typically used during the mid-quarter check-in process, this method enables evaluations for this OrganizationQuarter
  # if there are active students this quarter. Otherwise, it does nothing.
  def allow_evals_if_active
    update_attribute(:allow_evals, true) unless placements.filled.empty?
  end

  # Sends mid-quarter e-mails to this organization and activates or deactives for the next quarter. If the paramater is passed as
  # 'invite' then the organization will be activated for the next quarter. Otherwise, it will be marked as inactive.
  # This creates two potential sets of emails: evaluation emails and 
  # invitation emails. Evaluation emails get sent if there are any currently-placed students. Invitation emails get sent
  # if this organization is being invited for the next quarter.
  def queue_mid_quarter_emails(action = 'invite', unit = nil)
    send_evals = !placements.filled.empty?
    send_invites = (action == 'invite')
    
    emails = { 'Evaluate only' => [], 'Invite only' => [], 'Invite and Evaluate' => [] }
    
    # go through each primary contact and add to the two lists
    organization.primary_service_learning_contacts.each do |contact|
      emails['Evaluate only'] << contact if send_evals
      emails['Invite only']   << contact if send_invites
    end
    
    # add all the position supervisors and primary contacts to the eval list
    if send_evals
      emails['Evaluate only'] << placements.filled.collect(&:position).collect(&:supervisor)
      emails['Evaluate only'] << organization.primary_service_learning_contacts
    end
    
    # flatten the hashes
    emails['Evaluate only'] = emails['Evaluate only'].flatten.uniq.compact
    emails['Invite only']   = emails['Invite only'].flatten.uniq.compact
    
    # clean up to create the evals + invites list
    emails['Evaluate only'].each do |e|
      if emails['Invite only'].include?(e)
        emails['Invite and Evaluate'] << e
        emails['Invite only'].delete(e)
        emails['Evaluate only'].delete(e)
      end
    end

    # Define the command after delivery
    if action == 'invite'
      command_after_delivery = "Organization.find(#{organization.id}).activate_for(Quarter.find(#{quarter.next.id}), true, #{unit.id})"
    else
      command_after_delivery = "Organization.find(#{organization.id}).mark_inactive"
    end

    # send the emails
    emails.each do |type, recipients|
      recipients.each do |r|
        tmail_object = MID_QUARTER_EMAIL_TEMPLATES[type].create_email_to(r)
        EmailQueue.queue(r.person_id, tmail_object, nil, command_after_delivery)
        @emails_sent = true
      end
    end
    
    # Mark inactive if not inviting for next quarter -- this takes care of organizations that don't get any emails (and therefore
    # the command_after_delivery wouldn't be executed)
    organization.mark_inactive if action != 'invite' && !@emails_sent

  end
  
  # Updates the organization quater's position counts.
  # Called when a position is created, saved or destroyed
  def update_position_counts!
    counts = {
      :in_progress_positions_count => positions.in_progress.count,
      :pending_positions_count => positions.pending.count,
      :approved_positions_count => positions.approved.count
    }
    
    self.update_attributes(counts)
  end  
  
  # Called when a community partner submits a evaluation.
  def update_finished_evaluation!           
    self.update_attribute(:finished_evaluation, self.evaluation_status)
  end
  
  # Return evaluation status: false => In Progress(IP) tag, true => Finished (grenn-check-icon), or Not started yet as nil.
  def evaluation_status
    array = placements.filled.collect(&:evaluation_submitted?)
    if array.include?(false)
      status = array.include?(true) ? false : nil
    else
      status = array.empty? ? nil : true
    end
    status        
  end

end
