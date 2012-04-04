# Each Offering can be associated with one or more AwardTypes. This allows us to group Offerings together into some sense of relationship, especially for scholarships that are offered every quarter or every year. If an applicant is awarded in this Offering, then we consider him or her to be a recipient of that award type, such as "Mary Gates Scholar." Offerings can be attached to multiple AwardTypes to allow for more specificity; for example, someone who earns a Mary Gates Research Scholarship is both a "Mary Gates Research Scholar" and a generic "Mary Gates Scholar."
class OfferingAwardType < ActiveRecord::Base
  stampable
  
  belongs_to :offering
  belongs_to :award_type
  
  validates_presence_of :offering_id
  validates_presence_of :award_type_id
  
  delegate :scholar_title, :to => :award_type
  
end
