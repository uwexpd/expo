class OrganizationContactUnit < ActiveRecord::Base
  belongs_to :organization_contact
  belongs_to :unit
  
  
end