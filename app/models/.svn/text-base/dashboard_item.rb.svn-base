class DashboardItem < ActiveRecord::Base
  stampable
  has_many :offering_dashboard_items
  has_many :offerings, :through => :offering_dashboard_items, :source => :offering
  
end
