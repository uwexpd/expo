# An Organization can go through many statuses in a given Quarter. The OrganizationQuarter object has a method called +current_status+ that returns the most recent status of the OrganizationQuarter.
class OrganizationQuarterStatus < ActiveRecord::Base
  stampable
  belongs_to :organization_quarter
  belongs_to :organization_quarter_status_type
  
  validates_presence_of :organization_quarter_id
  validates_presence_of :organization_quarter_status_type
  
  delegate :title, :sequence, :to => :organization_quarter_status_type

  def type
    organization_quarter_status_type
  end
    
end
