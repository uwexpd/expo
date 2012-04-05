class AddGroupMemberToOfferingDashboardItem < ActiveRecord::Migration
  def self.up
    add_column :offering_dashboard_items, :show_group_members, :boolean
  end

  def self.down
    remove_column :offering_dashboard_items, :show_group_members
  end
end
