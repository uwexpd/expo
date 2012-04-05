class ApplicationGroupMember < ActiveRecord::Base
  include ActionController::UrlWriter
  stampable
  
  belongs_to :application_for_offering
  belongs_to :person
  
  has_one :token, :as => :tokenable
  after_save :create_token_if_needed

  has_many :guests, :class_name => "ApplicationGuest", :foreign_key => "group_member_id"
  belongs_to :nominated_mentor, :class_name => "ApplicationMentor", :foreign_key => "nominated_mentor_id"

  has_many :event_invitees, :include => {:event_time => :event}, :as => 'invitable' do
    def for_event(event); find(:all).select{|e| e.event == event }; end
  end

  
  validates_presence_of :application_for_offering_id
  validates_presence_of :lastname, :firstname, :email
  validates_inclusion_of :uw_student, :in => [true, false], :message => "selection must be either true or false"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :unless => proc { |obj| obj.uw_student? }
  validate :valid_uw_netid?
  validate :not_primary_applicant?
  
  before_validation_on_create :connect_to_student_record

  PLACEHOLDER_CODES = %w(validation_link fullname firstname lastname email verified? confirmed?)
  PLACEHOLDER_ASSOCIATIONS = %w(person application_for_offering)

  attr_accessor :validate_nominated_mentor
  validate :nominated_mentor_explanation_length, :if => :validate_nominated_mentor?
  validates_presence_of :nominated_mentor_id, :nominated_mentor_explanation, :if => :validate_nominated_mentor?
  def validate_nominated_mentor?; validate_nominated_mentor; end
  def nominated_mentor_explanation_length
    if nominated_mentor_explanation.split.size > 200
      overage = nominated_mentor_explanation.split.size - 200
      errors.add(:nominated_mentor_explanation, "must be less than 200 words. You need to remove #{overage} words.")
    end
  end
  
  attr_accessor :validate_theme_responses
  validate :theme_responses_validation, :if => :validate_theme_responses?
  def validate_theme_responses?; validate_theme_responses; end;
  def theme_responses_validation
    if theme_response.split.size > offering.theme_response_word_limit
      overage = theme_response.split.size - offering.theme_response_word_limit
      errors.add(:theme_response, "must be less than #{offering.theme_response_word_limit} words. You need to remove #{overage} words.")
    end
    if !offering.theme_response2_instructions.blank? && theme_response2.split.size > offering.theme_response2_word_limit
      overage = theme_response2.split.size - offering.theme_response2_word_limit
      errors.add(:theme_response2, "must be less than #{offering.theme_response2_word_limit} words. You need to remove #{overage} words.")
    end
  end
  
  
  delegate :offering, :project_title, :stripped_project_title, :current_status_name, :current_status, :passed_status?, :application_type_id, :application_type, :nominated_mentor, :submitted?, :to => :application_for_offering
  
  # Adds an extra custom validation to ensure that the supplied UW NetID is valid if this group member is a UW student. If a
  # person has been assigned to this group member already, then this method will *always* return true as long as the person
  # object is a +Student+, because we trust that anyone with a valid Student object already has a valid UW NetID in the student DB.
  def valid_uw_netid?
    return true if person.is_a?(Student) 
    if uw_student? and !StudentRecord.valid_uw_netid?(email)
      errors.add :email, "is not a valid UW NetID"
      return false
    end
  end
  
  # Ensures that this group member is not already the primary applicant for this application. You can't add yourself as a group member!
  def not_primary_applicant?
    if person_id == application_for_offering.person_id
      errors.add_to_base "You cannot add yourself as a group member if you are the primary applicant."
      person_id = nil
      return false
    end
    true
  end
  
  def <=>(o)
    lastname_first <=> o.lastname_first rescue 0
  end
  
  # Returns the fullname from the person record if we've associated one yet. Otherwise, calculate it from the name that the 
  # ApplicationForOffering owner put in. Note that we'll only use the person record if the group member has already been verified.
  # This allows us to comply with FERPA so that if a person puts in a valid UW NetID we do not automatically display the person's
  # name from the student database -- instead we wait until the student has logged in and verified their participation.
  def fullname
    return person.fullname if !person.nil? && verified?
    "#{firstname} #{lastname}"
  end
  
  # Similar to fullname.
  def lastname_first
    return person.lastname_first if !person.nil? && verified?
    "#{lastname}, #{firstname}"
  end

  # Similar to fullname, but with the email address.
  def email
    return person.email unless person.nil?
    read_attribute(:email)
  end
  
  def firstname_first
    return person.firstname_first unless person.nil?
    fullname
  end

  # The info_detail_line for a group member consists of: "[Firstname Lastname], [Class Standing], [Majors List], [Institution (if not UW)]"
  def info_detail_line(include_html = false, reference_quarter = nil)
    reference_quarter ||= Quarter.find_by_date(offering.deadline)
    info = []
    fp = "<span class=\"student_name\">" if include_html
    fs = "</span>" if include_html
    info << "#{fp}#{firstname_first}#{fs}"
    info << person.class_standing_description(:recent_graduate_placeholder => "Recent Graduate", :reference_quarter => reference_quarter) unless person.nil?
    mp = "<span class=\"student_major\">" if include_html
    ms = "</span>" if include_html
    info << "#{mp}#{person.majors_list(true, ", ", reference_quarter)}#{ms}" unless person.nil?
    info << person.institution_name if person && !person.institution.blank?
    info.compact.join(", ")
  end

  # Sends a validation email to this group member using the Offering's group_member_validation_email_template. This email includes
  # a link that allows a group member to go in and validate that they are, indeed, a part of the group.
  def send_validation_email
    e = TemplateMailer.deliver(offering.group_member_validation_email_template.create_email_to(self, validation_link))
    update_attribute(:validation_email_sent_at, Time.now) if e
    e
  end

  # Generates a link that can be used to connect to the validation page
  def validation_link
    apply_group_member_validation_url(
        :host => CONSTANTS[:base_url_host], 
        :offering => offering,
        :group_member_id => self,
        :token => token.to_s)
  end

  def app
    application_for_offering
  end

  # Update the person details
  def person_attributes=(person_attributes)
    if person
      person.update_attributes(person_attributes.reject{|k,v| k == :id})
    end
  end

  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!

  # Goes through this Offering's phase tasks (with "group_members" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    tasks ||= offering.tasks.find(:all, :conditions => "context = 'group_members' AND completion_criteria != ''")
    tasks = [tasks] unless tasks.is_a?(Array)
    for task in tasks
      tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
      tcs.result = self.instance_eval(task.completion_criteria.to_s)
      tcs.complete = tcs.result == true
      tcs.save
      self.task_completion_status_cache[task.id] = tcs.attributes
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

  # Attempts to populate person_id by searching for the student's UW NetID if the group member has been identified as a UW student.
  def connect_to_student_record
    self.person = Student.find_by_uw_netid(email) if uw_student?
  end
  
end
