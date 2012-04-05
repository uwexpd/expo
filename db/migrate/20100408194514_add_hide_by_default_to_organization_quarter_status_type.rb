class AddHideByDefaultToOrganizationQuarterStatusType < ActiveRecord::Migration
  def self.up
    add_column :organization_quarter_status_types, :hide_by_default, :boolean
  end

  def self.down
    remove_column :organization_quarter_status_types, :hide_by_default
  end
end
