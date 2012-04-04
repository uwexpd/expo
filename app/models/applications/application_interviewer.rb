# An ApplicationForOffering may be reviewed by one or more OfferingInterviewers.
class ApplicationInterviewer < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_interviewer

  validates_uniqueness_of :offering_interviewer_id, :scope => :application_for_offering_id
  
  def fullname
    offering_interviewer.person.fullname
  end

  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!
  after_save :update_committee_member_task_completion_status_cache!

  # Goes through this Offering's phase tasks (with "interviewers" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    tasks ||= offering.tasks.find(:all, :conditions => "context = 'interviewers' AND completion_criteria != ''")
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

  def update_committee_member_task_completion_status_cache!
    committee_member.update_task_completion_status_cache! if committee_member
    offering_interviewer.update_task_completion_status_cache! if offering_interviewer
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
