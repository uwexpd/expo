class OfferingCommitteeMemberRestriction < ActiveRecord::Base
  stampable
  belongs_to :offering
  belongs_to :committee_member_type
  
end
