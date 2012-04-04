# Defines a type of award, such as a scholarship, that a person can be defined as earning. This is useful for online applications to track what other scholarships a student has earned.
class AwardType < ActiveRecord::Base
  stampable
  belongs_to :unit
  has_many :offering_award_types
  has_many :offerings, :through => :offering_award_types
  
  validates_presence_of :title
  
  # Returns the scholar_title attribute, or, if blank, returns the scholarship title followed by " Scholar"
  def scholar_title
    read_attribute(:scholar_title).blank? ? "#{title} Scholar" : read_attribute(:scholar_title)
  end
  
  def <=>(o)
    title <=> o.title rescue -1
  end
  
end
