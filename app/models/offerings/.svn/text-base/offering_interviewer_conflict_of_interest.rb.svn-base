class OfferingInterviewerConflictOfInterest < ActiveRecord::Base
  stampable
  belongs_to :offering_interviewer
  belongs_to :application_for_offering
  
  validates_presence_of :offering_interviewer_id
  validates_presence_of :application_for_offering_id
  validates_uniqueness_of :offering_interviewer_id, :scope => :application_for_offering_id
  
  def applicant_name
    application_for_offering.person.fullname
  end
end
