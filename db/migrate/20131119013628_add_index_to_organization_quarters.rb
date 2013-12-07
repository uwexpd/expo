class AddIndexToOrganizationQuarters < ActiveRecord::Migration
  def self.up
    add_index :organization_quarters, :organization_id
  end

  def self.down
    remove_index :organization_quarters, :organization_id
  end
end
