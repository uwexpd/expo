# Each Offering allows for one or more awards to be presented to an applicant.  This is most useful in scholarship offerings.  In many cases, a scholarship will include multiple awards, such as a scholarship that renews for multiple years and is therefore processed as multiple disbersements into the university financial system.
#   
# The ApplicationAward model tracks the steps that an award goes through before it is dispersed to a student's account:
# 1.  +amount_requested+ is the amount that the student expects to receive if funded.  In most cases, this will be a fixed amount 
#     that is defined in the Offering definition, but in some cases, a student can actually request different amounts or different 
#     amounts per quarter.
# 2.  +amount_awarded+ is the amount that the selection committee decided to actually award the student.
# 3.  +amount_approved+ is the amount approved for disbersement, usually by the financial aid office.
# 4.  +amount_disbersed+ is the actual amount that was disbersed into the student's account.  In nearly all cases, this amount will match 
#     the amount_approved.
#     
# Each of these attributes include corresponding +notes+ fields and +user_id+ fields to help track the process.  In addition, two additional attributes are tracked:
# [+requested_quarter_id+]
#   The quarter for which the funding was originally requested by the student or assigned.
# [+disbersement_quarter_id+]
#   The quarter during which the award was actually disbersed. This might change during the approval process with financial aid, and is
#   the attribute that should be used for future reporting purposes.
# [+disbersement_type_id+]
#   The type of disbersement for the award.  Usually one of either +cash+ or +tuition+.  This value may be changed by the financial aid office.
class ApplicationAward < ActiveRecord::Base
  stampable
  belongs_to :application_for_offering
  validates_presence_of :application_for_offering_id
  belongs_to :requested_quarter, :class_name => "Quarter", :foreign_key => "requested_quarter_id"
  belongs_to :disbersement_type
  belongs_to :disbersement_quarter, :class_name => "Quarter", :foreign_key => "disbersement_quarter_id"
  belongs_to :amount_approved_user, :class_name => "User", :foreign_key => "amount_approved_user_id"
  belongs_to :amount_awarded_user, :class_name => "User", :foreign_key => "amount_awarded_user_id"
  belongs_to :amount_disbersed_user, :class_name => "User", :foreign_key => "amount_disbersed_user_id"
  acts_as_soft_deletable

  PLACEHOLDER_CODES = %w[ amount_requested amount_requested_notes amount_approved amount_approved_notes 
                          amount_awarded amount_awarded_notes amount_disbersed amount_disbersed_notes ]
  PLACEHOLDER_ASSOCIATIONS = %w[ application_for_offering requested_quarter disbersement_quarter disbersement_type amount_approved_user 
                          amount_awarded_user amount_disbersed_user ]
  
  attr_accessor :should_destroy
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def <=>(o)
    requested_quarter <=> o.requested_quarter rescue 1
  end

  # Calculates the number of hours to count this activity for accountability purposes. Returns nil if this application's
  # +hours_per_week+ is not defined.
  def number_of_hours
    hours_per_week = application_for_offering.hours_per_week
    return nil if hours_per_week.blank?
    hours_per_week.to_d * Activity::WEEKS_PER_QUARTER
  end
  
end
