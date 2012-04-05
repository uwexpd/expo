class AddNotCurrentToOrganizationContact < ActiveRecord::Migration
  def self.up
    add_column :organization_contacts, :current, :boolean, :default => 1
    execute "UPDATE `organization_contacts` SET `current` = 1"
    OrganizationContact::Deleted.update_columns
  end

  def self.down
    remove_column :organization_contacts, :current
    OrganizationContact::Deleted.update_columns
  end
end
