# Holds the possible options that can be selected for an OrganizationQuarter's status.
class OrganizationQuarterStatusType < ActiveRecord::Base
  stampable
  has_many :organization_quarter_statuses
  has_many :organization_quarters, :through => :organization_quarter_statuses
  
  validates_presence_of :title
  
  def organization_quarters_where_current(quarter_id = nil)
    oqs = organization_quarters.reject{|oq| oq.status.type != self }
    oqs.reject!{|oq| oq.quarter_id != quarter_id } unless quarter_id.nil?
    oqs
  end
  
end
