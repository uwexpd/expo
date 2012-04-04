# When an Offering uses a formal review process, this model is used to define the criteria on which an ApplicationForOffering should be scored. Each ApplicationReviewer will submit a score and comments for each OfferingReviewCriterion for an application.
class OfferingReviewCriterion < ActiveRecord::Base
  stampable
  belongs_to :offering
  
  validates_presence_of :offering_id
  validates_presence_of :title
  validates_uniqueness_of :sequence, :scope => :offering_id
  
  def <=>(o)
    sequence <=> o.sequence
  end
  
end
