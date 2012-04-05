class OfferingInterviewInterviewer < ActiveRecord::Base
  stampable
  belongs_to :offering_interview
  belongs_to :offering_interviewer

  has_many :scores, :class_name => "OfferingInterviewInterviewerScore"

  delegate :applicant, :to => :offering_interview
  
  def person
    offering_interviewer.person
  end
  
  def fullname
    person.fullname
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
    scores.collect{|s| s.score || 0}.sum
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

  # # Returns the average score for this CommitteeMember for all scores of this criterion.
  # def reviewer_average_score(criterion)
  #   committee_member.application_reviewers.collect{|r| r.get_score(criterion) rescue nil}.compact.average
  # end
  # 
  # # Returns the average score for this CommitteeMember for all total scores.
  # def reviewer_total_average_score
  #   committee_member.application_reviewers.collect{|r| r.total_score rescue nil}.compact.average
  # end
  
  # Creates an ApplicationReviewScore object for each associated OfferingReviewCriterion for this ApplicationForOffering's Offering.
  # Use this method to initialize a reviewer's score card before they begin reviewing with the reviewer interface.
  def create_scores
    for review_criterion in applicant.offering.review_criterions
      scores.create(:offering_review_criterion_id => review_criterion.id) unless scores.find_by_offering_review_criterion_id(review_criterion)
    end
  end

  # Allows the application's +application_interview_decision_type_id+ to be set using the same form as the interviewer scoring pane.
  # This will only be honored if this OfferingInterviewInterviewer is a +committee_score+.
  def application_interview_decision_type_id=(new_type_id)
    return false unless committee_score?
    applicant.update_attribute(:application_interview_decision_type_id, new_type_id)
  end
  
  delegate :application_interview_decision_type_id, :to => :applicant

  # Allows the application's +interview_feedback_person_id+ to be set using the same form as the interviewer scoring pane.
  # This will only be honored if this OfferingInterviewInterviewer is a +committee_score+.
  def interview_feedback_person_id=(new_person_id)
    return false unless committee_score?
    applicant.update_attribute(:interview_feedback_person_id, new_person_id)
  end
  
  delegate :interview_feedback_person_id, :to => :applicant
  
  
end
