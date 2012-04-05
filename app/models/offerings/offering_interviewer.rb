# An OfferingInterviewer is a person who has been identified as an interviewer for a certain Offering. An OfferingInterviewer record connects a Person with an Offering so that staff can assign an OfferingInterviewer to each ApplicationForOffering.
class OfferingInterviewer < ActiveRecord::Base
  stampable
  belongs_to :person_record, :class_name => "Person", :foreign_key => "person_id"
  belongs_to :offering
  belongs_to :committee_member
  
  # has_many :application_interviewers, :dependent => :destroy
  # has_many :applications_for_review, :through => :application_interviewers, :source => :application_for_offering
  has_many :interview_availabilities, :dependent => :nullify
  has_many :conflict_of_interests, :class_name => "OfferingInterviewerConflictOfInterest", :dependent => :destroy
  has_many :offering_interview_interviewers, :dependent => :destroy
  has_many :offering_interviews, :through => :offering_interview_interviewers, :source => :offering_interview
  belongs_to :invite_email, :class_name => "EmailContact", :foreign_key => "invite_email_contact_history_id"
  belongs_to :interview_times_email, :class_name => "EmailContact", :foreign_key => "interview_times_email_contact_history_id"

  validates_presence_of :person_id
  validates_presence_of :offering_id
  validates_uniqueness_of :person_id, :scope => :offering_id  
  
  delegate :committee_member_type, :to => :committee_member
  delegate :fullname, :firstname, :lastname, :lastname_first, :firstname_first, :to => :person

  PLACEHOLDER_CODES = %w()
  PLACEHOLDER_ASSOCIATIONS = %w(person offering)
  
  attr_accessor :uw_person
  
  def person
    if committee_member.nil?
      person_record rescue nil
    else
      committee_member.person rescue nil
    end
  end
  
  def person_name
    person.fullname
  end
  
  # Returns true if the applicant has identified themselves as being available for an interview at a certain time
  def available_for_interview?(time, timeblock)
    available = !interview_availabilities.find_by_time_and_offering_interview_timeblock_id(time.to_time, timeblock).nil?
  end
  
  # Returns true if the interviewer has recused him or herself from interviewing the specified application's student
  def recused_from?(a)
    !conflict_of_interests.find_by_application_for_offering_id(a.id).nil?
  end

  # Returns true if this OfferingInterviewer is scheduled to participate in the OfferingInterview that is supplied.
  def interviewing_at?(offering_interview)
    return false if offering_interview.nil?
    offering_interview.offering_interviewers.include? self
  end

  # Returns true if this OfferingReviewer has submitted any times of availability. It's possible that this person has
  # gone in and left because they weren't available for _any_ times, and this method will still return false.
  def responded_with_availability?
    !interview_availabilities.empty?
  end

  def average_score(*opts)
    0.0
  end

  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!

  # Goes through this Offering's phase tasks (with "interviewer" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    tasks ||= offering.tasks.find(:all, :conditions => "context = 'interviewers' AND context_object_completion_criteria != ''")
    tasks = [tasks] unless tasks.is_a?(Array)
    for task in tasks
      tcs = task_completion_statuses.find_or_create_by_task_id(task.id)
      tcs.result = self.instance_eval(task.context_object_completion_criteria.to_s)
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
  
end
