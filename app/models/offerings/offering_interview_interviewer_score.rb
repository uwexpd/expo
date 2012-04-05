class OfferingInterviewInterviewerScore < ActiveRecord::Base
  stampable
  belongs_to :offering_interview_interviewer
  belongs_to :offering_review_criterion
  
  validates_presence_of :offering_review_criterion_id
  validates_numericality_of :score, :allow_nil => true
  validates_uniqueness_of :offering_review_criterion_id, :scope => :offering_interview_interviewer_id
  
  delegate :max_score, :to => :offering_review_criterion

  # Custom validation to check that the score supplied is not higher than the maximum score allowed for this OfferingReviewCriterion.
  def validate
    if offering_review_criterion && !score.blank? && score > max_score
      errors.add(:score, "cannot be greater than the maximum score of #{max_score}") 
    end
  end
  
  
end