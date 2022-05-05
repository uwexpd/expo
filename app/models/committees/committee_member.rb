class CommitteeMember < ActiveRecord::Base
  stampable
  belongs_to :committee
  belongs_to :person
  belongs_to :recommender, :class_name => "CommitteeMember", :foreign_key => "recommender_id"
  belongs_to :committee_member_type
  has_many :offering_sessions, :class_name => "OfferingSession", :foreign_key => "moderator_id" do
    def for(offering)
      find(:all, :conditions => { :offering_id => offering })
    end
  end
  has_many :committee_member_quarters do
    def upcoming(limit = 4, reference_quarter = Quarter.current_quarter)
      reject{|q| q.quarter < reference_quarter}.sort[0..(limit-1)]
    end
  end
  
  has_many :committee_member_meetings do
    def future
      reject{|m| m.meeting.past? }
    end
  end
  
  has_many :committee_quarters, :through => :committee_member_quarters
#  has_many :quarters, :through => :committee_quarters
  
  has_many :application_reviewers do
    def for(offering)
      # find_all{|r| r.application_for_offering.offering == offering rescue nil }.compact
      find(:all, :joins => :application_for_offering, :conditions => { "application_for_offerings.offering_id" => (offering.is_a?(Offering) ? offering.id : offering)})
    end
  end
  has_many :applications_for_review, :through => :application_reviewers, :source => :application_for_offering do
    def for(offering)
      find(:all, :conditions => { :offering_id => (offering.is_a?(Offering) ? offering.id : offering) })
    end
  end

  has_many :application_interviewers do
    def for(offering)
      # find_all{|r| r.application_for_offering.offering == offering rescue nil }.compact
      find(:all, :joins => :application_for_offering, :conditions => { "application_for_offerings.offering_id" => (offering.is_a?(Offering) ? offering.id : offering)})
    end
  end
  has_many :applications_for_interview, :through => :application_interviewers, :source => :application_for_offering do
    def for(offering)
      find(:all, :conditions => { :offering_id => (offering.is_a?(Offering) ? offering.id : offering) })
    end
  end
  
  has_many :contact_histories, :as => :contactable
  
  delegate :fullname, :firstname_first, :lastname_first, :firstname, :lastname, :to => :person
  
  validates_presence_of :person, :committee_id
  validates_uniqueness_of :person_id, :scope => :committee_id, :message => "already exists as part of this committee"
  validate :person_is_valid, :unless => :skip_person_validations
  
  attr_accessor :skip_person_validations
  def person_is_valid
    if person
      person.require_validations = true
      person.errors.each_full{ |e| errors.add_to_base(e) } unless person.valid?
    end
  end

  after_save :create_committee_member_quarters_if_needed
  after_save :create_committee_member_meetings_if_needed
  
  has_one :token, :as => :tokenable
  after_save :create_token_if_needed
  after_validation :update_status_cache!
  
  PLACEHOLDER_CODES = %w(login_url current_symposium_session)
  PLACEHOLDER_ASSOCIATIONS = %w(person committee)

  DEFAULT_RESPONSE_LIFETIME = 9.months

  def <=>(o)
    person <=> o.person rescue -1
  end

  # Returns true as long as +inactive+ and +permanently_inactive+ are both set to +false+.
  def currently_active?
    @currently_active ||= !inactive? && !permanently_inactive?
  end
  
  # Returns true if the user has responded (based on last_user_response_at) to an availability request within the
  # response_lifetime provided (default is 9 months). Or, if this Committee has a response_reset_date set, return true
  # if this member's last_user_response_at is newer than the response_reset_date.
  def responded_recently?(response_lifetime = DEFAULT_RESPONSE_LIFETIME)
    if committee && committee.response_reset_date
      last_user_response_at > committee.response_reset_date rescue false
    else
      Time.now - last_user_response_at < response_lifetime rescue false
    end
  end
  
  # Returns the current "status" as a Symbol. Choices are :active, :inactive, :not_responded, and :permanently_inactive.
  def status
    return :permanently_inactive if permanently_inactive?
    return :active if currently_active? && responded_recently?
    return :not_responded if currently_active? && !responded_recently?
    return :inactive if !currently_active?
  end
  
  # Set the status for this committee member. Since CommitteeMember objects don't technically have a +status+ attribute,
  # (we calculate the status based on a couple of other fields) this method does different things depending on the new status passed.
  # The new status can be passed as a String or a Symbol.
  def status=(new_status)
    return false if new_status.blank?
    new_status = new_status.to_sym
    case new_status
    when :active then update_attribute(:inactive, false) && update_attribute(:permanently_inactive, false)
    when :inactive then update_attribute(:inactive, true)
    when :permanently_inactive then update_attribute(:permanently_inactive, true)
    end
    self.update_status_cache!
  end
  
  def update_status_cache!
    self.update_attribute(:status_cache, self.status.to_s)
  end
  
  # Checks if the number of applications assigned to this reviewer is less than the amount specified in the
  # +max_number_of_applicants_per_reviewer+ attribute of this Member's CommitteeMemberType. If an Offering object is passed,
  # then we base the result on assignments for the current offering only.
  def full?(offering = nil)
    return false if committee_member_type.nil?
    return false if committee_member_type.max_number_of_applicants_per_reviewer.blank?
    return applications_for_review.size >= committee_member_type.max_number_of_applicants_per_reviewer if offering.nil?
    applications_for_review.for(offering).size >= committee_member_type.max_number_of_applicants_per_reviewer
  end
  
  # Returns true if this CommitteeMember has a CommitteeMemberQuarter record for the specified quarter.
  def active_for?(q)
    if cq = CommitteeQuarter.find_by_committee_id_and_quarter_id(committee.id, q.id)
      cmq = committee_member_quarters.find_or_create_by_committee_quarter_id(cq.id)
      return cmq.active?
    end
    false
  end

  # Computes the average score that this committee member has given to applications_for_review. An Offering can be specified to
  # to limit the selection to only a specific Offering review process. If a review_criterion 
  # is specified, then the average scores for only that criterion is computed.
  def average_score(offering = nil, offering_review_criterion = nil)
    application_reviewers_set = offering.nil? ? application_reviewers : application_reviewers.for(offering)
    if offering_review_criterion.nil?
      scores = application_reviewers_set.collect{|r| (r.started_scoring? ? r.total_score.to_f : nil) rescue nil }.compact
    else
      scores = application_reviewers_set.collect{|r| (r.started_scoring? ? (r.get_score(offering_review_criterion).to_f rescue nil) : nil ) || nil }.compact
    end
    scores.sum/scores.size rescue 0.0
  end

  def login_url
    token.generate rescue create_token
    "http://#{CONSTANTS[:base_system_url]}/committee_member/map/#{id}/#{token.token}"
  end
  
  def current_symposium_session
    current = offering_sessions.last    
    "Session: #{current.title}\nLocation: #{current.location}\nTime:#{current.time_detail}"
  end 

  def create_committee_member_quarters_if_needed
    if committee
      committee.committee_quarters.each do |committee_quarter|
        committee_member_quarters.find_or_create_by_committee_quarter_id(committee_quarter.id)
      end
    end
  end

  def create_committee_member_meetings_if_needed
    if committee
      committee.meetings.each do |committee_meeting|
        committee_member_meetings.find_or_create_by_committee_meeting_id(committee_meeting.id)
      end
    end
  end

  def committee_member_quarter_attributes=(quarter_attributes)
    quarter_attributes.each do |id, attributes|
      committee_member_quarters.find(id.to_i).update_attributes(attributes)
    end
  end

  def committee_member_meeting_attributes=(meeting_attributes)
    meeting_attributes.each do |id, attributes|
      committee_member_meetings.find(id.to_i).update_attributes(attributes)
    end
  end

  
  # # Pass a hash of to change the active quarters for this CommitteeMember
  # def active_for=(quarters_hash)
  #   quarters_hash.each do |id, h|
  #     if q = CommitteeQuarter.find_by_quarter_id(id)
  #       cmq = committee_member_quarters.find_or_create_by_committee_quarter_id(q.id)
  #       cmq.update_attributes(h)
  #     end
  #   end
  # end
  # 
  # def quarter_comments=(comments_hash)
  #   comments_hash.each do |id, h|
  #     if q = CommitteeQuarter.find_by_quarter_id(id)
  #       cmq = committee_member_quarters.find_or_create_by_committee_quarter_id(q.id)
  #       cmq.update_attributes(h)
  #     end
  #   end
  # end
  # 
  def quarter_comment_for(q)
    if cq = CommitteeQuarter.find_by_committee_id_and_quarter_id(committee.id, q.id)
      cmq = committee_member_quarters.find_or_create_by_committee_quarter_id(cq.id)
      return cmq.comment
    end
  end
  
  # Returns true if active_for? the current quarter (defined by Quarter.current_quarter)
  def active?
    self.active_for?(Quarter.current_quarter)
  end

  # Create a new person record through mass update.
  def new_person_attributes=(new_person_attributes)
    if new_person_attributes[:id] == "-1"
      build_person(new_person_attributes.reject{|k,v| k == :id})
    elsif person
      person.update_attributes(new_person_attributes.reject{|k,v| k == :id}) if person_is_valid
    elsif person = (Person.find(new_person_attributes[:id]) rescue nil)
      person.update_attributes(new_person_attributes.reject{|k,v| k == :id})
    end
  end

  # Checks to see if this committee member is allowed to view an ApplicationForOffering that may not be assigned to them.
  # This method will return true if any of the applications_for_review include the specified ApplicationForOffering in its
  # +past_applications+ method; otherwise, return false. Note that this might be slow to run (fix it later?).
  def ok_to_view_past_application?(past_app)
    applications_for_review.each do |a|
      return true if a.past_applications.collect(&:id).include?(past_app.id)
    end
    return false
  end

  # Returns the associated person's department, or the local department name of this record otherwise.
  def department_name
    person.department_name.blank? ? department : person.department_name rescue department_name
  end

  # Returns true if this CommitteeMember has any contact_histories that are newer than the Committee +response_lifetime_date+.
  def contacted_recently?
    !contact_histories.find(:all, :conditions => ["created_at > ?", committee.response_lifetime_date]).empty?
  end

  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!

  # Goes through this Offering's phase tasks (with "reviewer" or "interviewer" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    for offering in applications_for_review.collect(&:offering).uniq
      tasks ||= offering.tasks.find(:all, 
                                    :conditions => "(context = 'reviewers' OR context = 'interviewers') 
                                                    AND context_object_completion_criteria != ''")
      tasks = [tasks] unless tasks.is_a?(Array)
      for task in tasks
        tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
        tcs.result = self.instance_eval("@offering ||= Offering.find(#{task.offering.id}); #{task.context_object_completion_criteria.to_s}")
        tcs.complete = tcs.result == true
        tcs.save
        self.task_completion_status_cache[task.id] = tcs.attributes
      end
    end
    task_completion_status_cache
  end

  # Returns the task completion status hash for the specified task out of the +task_completion_status_cache+ hash. If the cache hasn't
  # been generated yet, this forces a reload (you can also manually force a reload by pass +true+ for +force_reload+).
  def task_completion_status(task_id, force_update = false)
    save if task_completion_status_cache.nil? || force_update
    task_completion_status_cache[task_id]
  end

  # Marks a certain task complete. Note that this should only be done for tasks that don't have a +completion_criteria+ set,
  # otherwise your action here will get overridden when #update_task_completion_status_cache! is run.
  def complete_task(task)
    self.task_completion_status_cache ||= {}
    task = OfferingAdminPhaseTask.find(task) unless task.is_a?(OfferingAdminPhaseTask)
    tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
    tcs.result = true
    tcs.complete = true
    tcs.save
    self.task_completion_status_cache[task.id] = tcs.attributes
    tcs
  end


  protected
  
  def create_token_if_needed
    create_token if token.nil?
  end
  
end
