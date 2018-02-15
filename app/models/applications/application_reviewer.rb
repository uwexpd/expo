# An ApplicationForOffering may be reviewed by one or more OfferingReviewers. The ApplicationReviewer table keeps the scores that the OfferingReviewer has given to the associated ApplicationForOffering.
class ApplicationReviewer < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_reviewer
  belongs_to :committee_member

  has_many :scores, :class_name => "ApplicationReviewerScore"

#  validates_uniqueness_of :offering_reviewer_id, :scope => :application_for_offering_id
  validates_presence_of :application_for_offering_id
  validates_uniqueness_of :committee_member_id, :scope => :application_for_offering_id
  validates_associated :scores
  
  delegate :offering_id, :offering, :to => :application_for_offering
  delegate :fullname, :to => :person
  delegate :committee_member_type, :to => :committee_member
  
  MAX_SPREAD = 4
  
  def person
    if committee_member.nil?
      offering_reviewer.person rescue nil
    else
      committee_member.person rescue nil
    end
  end
  

  # Mass-assign new attributes for this ApplicationReviewer's scores.
  def score=(score_attributes)
    score_attributes.each do |score_id, score_attributes|
      scores.find(score_id).update_attributes(score_attributes)
    end
  end

  # Returns true if this object has any valid scores. Use this to determine if the ApplicationReviewer has started the scoring
  # process. Note that this does *not necessarily* mean that the reviewer has finished scoring.
  def started_scoring?
    !scores.empty?
  end

  # Calculates the total score of all ApplicationReviewerScores
  def total_score
    @total_score ||= scores.collect{|s| s.score || 0}.sum
  end
  
  # Compares this reviewer's total score with that of the other reviewers for this application_for_offering and returns true if this
  def total_score_is_outlier?
    false
  end
  
  # Provides the score value that this reviewer has submitted for the specified OfferingReviewCriterion.
  # If a score has not been provided, this method returns either nil or 0:
  #  * If started_scoring? is true, return 0 so that all empty scores will be displayed as a 0
  #  * If started_scoring? is false, return nil.
  def get_score(criterion)
    return nil unless criterion.is_a?(OfferingReviewCriterion)
    result = scores.find_by_offering_review_criterion_id(criterion.id)
    return nil if result.nil?
    result.score.blank? ? (started_scoring? ? 0 : nil) : result.score
  end

  # Provides the comment that this reviewer has submitted for the specified OfferingReviewCriterion.
  def get_comment(criterion)
    return nil unless criterion.is_a?(OfferingReviewCriterion)
    result = scores.find_by_offering_review_criterion_id(criterion.id)
    result.comments rescue nil
  end

  # Returns the average score for this CommitteeMember for all scores of this criterion.
  def reviewer_average_score(criterion)
    # committee_member.application_reviewers.collect{|r| r.get_score(criterion) rescue nil}.compact.average
    committee_member.application_reviewers.find(:all, 
      :joins => :scores, 
      :select => "AVG(score) AS average_score",
      :conditions => ["application_reviewer_scores.offering_review_criterion_id = #{criterion.id}"]).first.average_score
  end
  
  # Returns the average score for this CommitteeMember for all total scores for this Offering.
  def reviewer_total_average_score
    # committee_member.application_reviewers.for(offering).collect{|r| r.total_score rescue nil}.compact.average
    committee_member.application_reviewers.find(:all, 
      :joins => :scores, 
      :select => "SUM(score) AS summed_score",
      :group => 'application_for_offering_id').collect{|s| s.summed_score.to_i}.average
  end
  
  # Creates an ApplicationReviewScore object for each associated OfferingReviewCriterion for this ApplicationForOffering's Offering.
  # Use this method to initialize a reviewer's score card before they begin reviewing with the reviewer interface.
  def create_scores
    for review_criterion in application_for_offering.offering.review_criterions
      scores.create(:offering_review_criterion_id => review_criterion.id) unless scores.find_by_offering_review_criterion_id(review_criterion)
    end
  end

  # Allows the application's +application_review_decision_type_id+ to be set using the same form as the reviewer scoring pane.
  # This will only be honored if this ApplicationReviewer is a +committee_score+.
  def application_review_decision_type_id=(new_type_id)
    return false unless committee_score?
    application_for_offering.update_attribute(:application_review_decision_type_id, new_type_id)
  end
  
  delegate :application_review_decision_type_id, :to => :application_for_offering

  # Allows the application's +feedback_person_id+ to be set using the same form as the reviewer scoring pane.
  # This will only be honored if this ApplicationReviewer is a +committee_score+.
  def feedback_person_id=(new_person_id)
    return false unless committee_score?
    application_for_offering.update_attribute(:feedback_person_id, new_person_id)
  end
  
  delegate :feedback_person_id, :to => :application_for_offering

  serialize :task_completion_status_cache
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!
  after_save :update_committee_member_task_completion_status_cache!

  # Goes through this Offering's phase tasks (with "reviewers" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
    self.task_completion_status_cache ||= {}
    tasks ||= offering.tasks.find(:all, :conditions => "context = 'reviewers' AND completion_criteria != ''")
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

  def toggle_finalized
    update_attribute :finalized, !finalized?
    finalized?
  end

  
end
