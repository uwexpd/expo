# Connects AwardTypes to Offerings. This is useful to specify which award types we should ask a student about when they are applying for a specific Offering.
class OfferingOtherAwardType < ActiveRecord::Base
  stampable
  belongs_to :award_type
  belongs_to :offering
  
  delegate :title, :scholar_title, :unit, :offerings, :to => :award_type
  
  def <=>(o)
    title <=> o.title rescue 0
  end
  
end
