class AddSequenceToOfferingDashboardItem < ActiveRecord::Migration
  def self.up
    add_column :offering_dashboard_items, :sequence, :integer
  end

  def self.down
    remove_column :offering_dashboard_items, :sequence
  end
end
