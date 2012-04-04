# Places a restriciton on the associated Offering record.  Subclasses of this class override the three methods in the model.  The primary method, allows?, takes an ApplicationForOffering object and executes code to make sure that the given ApplicationForOffering is allowed to continue.
# A common OfferingRestriction would be the PastDeadlineRestriction, which disallows an application to continue if the deadline for the Offering has passed.  Another example is the FulltimeStudentRestriction, which checks that a student is enrolled in enough credits to be eligible for the associated Offering.
# Also see OfferingRestrictionExemption.
class OfferingRestriction < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :exemptions, :class_name => "OfferingRestrictionExemption"
  
  # Constants
  TITLE = "You are restricted from completing this application."
  DETAIL = "You must satisfy the conditions of the restriction before you may continue."
  
  # Runs this restriction's validation tests and returns true or false.  This is only used in subclasses of OfferingRestriction.
  # If true, then this restriction definition allows the application to go through.
  def allows?(application_for_offering)
    return true
  end
  
  def exempt?(application_for_offering)
    exemption = OfferingRestrictionExemption.find_last_by_person_id_and_offering_restriction_id(application_for_offering.person.id, self.id)
    !exemption.nil? && exemption.valid_until > Time.now
  end
  
  def title
    TITLE
  end
  
  def detail
    DETAIL
  end
  
end
