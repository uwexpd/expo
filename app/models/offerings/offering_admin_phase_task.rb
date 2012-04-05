class OfferingAdminPhaseTask < ActiveRecord::Base
  stampable
  belongs_to :offering_admin_phase
  has_many :extra_fields, :class_name => "OfferingAdminPhaseTaskExtraField" 
  delegate :offering, :to => :offering_admin_phase
  acts_as_list :column => 'sequence'
  default_scope :order => "sequence"
  validates_presence_of :title
  
  attr_accessor :update_task_completion_status_caches_after_save
  
  def <=>(o)
    sequence.to_i <=> o.sequence.to_i rescue 0
  end
  
  def display_as
    read_attribute(:display_as).blank? ? (title || "").gsub(" ","_").underscore : read_attribute(:display_as)
  end
  
  alias :phase :offering_admin_phase
  
  # Defines the attributes that are relevant for a certain task type. This is used to modify the "edit task" interface
  # to be more user-friendly and only show the fields that matter.
  RELEVANT_ATTRIBUTES = {
    :send_to_financial_aid => %w[application_status_types],
    :update_status_email => %w[application_status_types],
    :applicant_list => %w[application_status_types, applicant_list_criteria],
    :send_email => %w[application_status_types, applicant_list_criteria, email_templates],
    :assign_reviewers => %w[application_status_types, new_application_status_type],
    :change_status_invited_to_interview => %w[application_status_types, new_application_status_type],
    :change_status => %w[application_status_types, new_application_status_type, applicant_list_criteria],
    :notify_dean => %w[application_status_types, new_application_status_type, applicant_list_criteria],
    :link => %w[detail_text, url],
    :update_template_email => %w[email_templates],
    :send_interviewer_email => %w[email_templates, reviewer_list_criteria],
    :send_reviewer_email => %w[email_templates, reviewer_list_criteria],
    :closing => %w[],
    :identify_interviewers => %w[],
    :interview_times => %w[],
    :mass_input_review_decisions => %w[],
    "" => %w[]
  }
  
  # Parse the +application_status_types+ field and return an array of the associated ApplicationStatusTypes.
  # The field can be separated by +\n, |+, or space.
  def application_status_types
    raw = read_attribute(:application_status_types)
    return [] if raw.blank?
    arr = []
    raw.split(/[\n\|\s]/).each{ |name| arr << ApplicationStatusType.find_by_name(name)}
    arr.compact
  end

  # Parse the +new_application_status_types+ field and return an array of the associated ApplicationStatusTypes.
  # The field can be separated by +\n, |+, or space.
  def new_application_status_types
    raw = read_attribute(:new_application_status_type)
    return [] if raw.blank?
    arr = []
    raw.split(/[\n\|\s]/).each{ |name| arr << ApplicationStatusType.find_by_name(name)}
    arr.compact
  end

  # Parse the +email_templates+ field and return an array of the associated EmailTemplates.   
  # The field can be separated by +\n or |+.
  def email_templates
    raw = read_attribute(:email_templates)
    return [] if raw.blank?
    arr = []
    raw.split(/[\n\|]/).each do |name| 
      t = EmailTemplate.find_or_create_by_name(name)
      t.update_attribute(:from, offering.contact_email) if t.from.blank?
      arr << t
    end
    arr.compact
  end

  # Checks to see if there is a value defined in +progress_column_title+ and returns that if there is. Otherwise, returns
  # the task title.
  def progress_column_title
    read_attribute(:progress_column_title).blank? ? title : read_attribute(:progress_column_title)
  end

  # Shortcut to check if this task uses the requested context type. Pass a symbol or string for the context type name.
  def context?(context_type)
    context == context_type.to_s
  end

  # Returns the relevant records depending on the context, based on the phase's settings for status, etc.
  def relevant_records
    case context
    when "applicant"      then  phase.all_applications
    when "mentors"        then  phase.all_applications.collect(&:mentors).flatten
    when "group_members"  then  phase.all_applications.collect(&:group_members).flatten
    when "reviewers"      then  (phase.all_applications.collect{|a| a.reviewers.without_committee_scores} + offering.reviewers).flatten
    when "interviewers"   then  (phase.all_applications.collect(&:interviewers) + offering.interviewers).flatten
    end
  end

  # Updates the completion status cache for the relevant records by calling the update method with this task as the parameter.
  # Then saves the relevant records.
  def update_task_completion_status_caches!
    return nil if completion_criteria.blank? && context_object_completion_criteria.blank?
    logger.info { "Updating task completion status cache for OfferingAdminPhaseTask id #{id}" }
    for r in relevant_records
      r.update_task_completion_status_cache!(self)
      r.save
    end
  end

  # Marks this task as complete for the passed object, if the object accepts task completion statuses.
  def complete_for(object)
    object.complete_task(self) if object.respond_to?(:complete_task)
  end

  protected
  
  # Returns an Array of possible options that can be used for #display_as by collecting all partial files in the 
  # /views/admin/apply/phase directory. Each item in the array is a hash consisting of a :name and :title for each option --
  # :name should be the value stored in the record and :title can be used for display purposes.
  def self.display_as_options
    Dir.glob("app/views/admin/apply/phase/*.rhtml").collect do |f|
      { :name =>  f[/_(.*).rhtml/, 1],
        :title => (f[/_(.*).rhtml/, 1].titleize rescue nil)
      }
    end
  end
  
end
