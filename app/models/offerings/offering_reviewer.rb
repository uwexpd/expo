# An OfferingReviewer is a person who has been identified as a reviewer for a certain Offering. An OfferingReviewer record connects a Person with an Offering so that staff can assign an OfferingReviewer to each ApplicationForOffering.
class OfferingReviewer < ActiveRecord::Base
  stampable
  belongs_to :person
  belongs_to :offering
  has_many :application_reviewers, :dependent => :destroy
  has_many :applications_for_review, :through => :application_reviewers, :source => :application_for_offering
  
  validates_presence_of :person_id
  validates_presence_of :offering_id
  validates_uniqueness_of :person_id, :scope => :offering_id
  
  def person_name
    person.fullname
  end
  
end
