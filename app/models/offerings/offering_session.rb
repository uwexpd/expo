# Models a moderated session that can be associated with an Offering. This was first created to support moderated sessions at the Undergraduate Research Symposium, where multiple ApplicationForOfferings can be assigned to a moderated session along with a Moderator that is pulled from the Offering's moderators committee (defined by +moderator_committee_id+).
class OfferingSession < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :moderator, :class_name => "CommitteeMember", :foreign_key => "moderator_id"
  has_many :presenters, :class_name => "ApplicationForOffering", :include => :person,
                        :order => "offering_session_order, people.lastname" do 
    def with_easel_numbers; find(:all, :conditions => "easel_number IS NOT NULL AND easel_number != ''"); end
  end
  has_many :group_members, :through => :presenters
  belongs_to :application_type, :class_name => "OfferingApplicationType", :foreign_key => "offering_application_type_id"
  
  validates_presence_of :offering_id, :title
  validates_uniqueness_of :title, :scope => :offering_id
  validates_uniqueness_of :moderator_id, :scope => :offering_id, :allow_nil => true,
                          :message => "has already been assigned to another session."
  
  PLACEHOLDER_CODES = %w(title identifier time_detail)
  PLACEHOLDER_ASSOCIATIONS = %w(offering moderator application_type)
  
  attr_accessor :require_new_title
  validate :title_has_changed, :if => :require_new_title
  def title_has_changed
    errors.add :title, "must be changed from the temporary one" if title_is_temporary?
  end
  
  # When setting this session as "finalized" we also automatically set the +finalized_date+ to Time.now.
  def finalized=(bool)
    self.write_attribute(:finalized, bool)
    self.write_attribute(:finalized_date, (bool == "1" ? Time.now : nil))
  end

  # A printable representation of this session's time, like "3:00 pm to 5:30 pm". Specify a delimiter (default is "to")
  def time_detail(delimiter = "to")
    result = start_time.to_s(:time12)
    result << " #{delimiter} " + end_time.to_s(:time12) if end_time
    result
  end
  
  # Returns a modified title to allow us to include things like the session identifier. Valid Options include:
  def title(options = {})
    raw_title = read_attribute(:title)
    id_text = "Session #{identifier}" unless identifier.blank?
    return "#{id_text + ': ' unless id_text.nil?}#{raw_title}" if options[:include_identifier]
    return "#{id_text}" if options[:identifier_only] && !identifier.blank?
    return "#{raw_title}"
  end

  # Returns true if any of this session's presenters have a value in the +easel_number+ column.
  def easel_numbers_assigned?
    !presenters.with_easel_numbers.empty?
  end
  
end
