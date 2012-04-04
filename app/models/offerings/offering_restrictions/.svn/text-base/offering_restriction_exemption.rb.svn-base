# Allows admins to provide an exemption to applicants to get passed certain restrictions placed on the application process.  This is only for "special cases."  For example, a student may be applying for an Offering that requires him to be a full-time student but he is a credit short because of an extenuating circumstance.  Administrators may decide to offer the student an exemption in that case by creating an OfferingRestrictionExemption for that student.
#   
# The OfferingRestriction and Person records are required.  A note and an expiration date (in the +valid_until+ attribute) can also be specified.
class OfferingRestrictionExemption < ActiveRecord::Base
  validates_presence_of :offering_restriction_id
  validates_presence_of :person_id

  belongs_to :person
  belongs_to :offering_restriction
  
end
