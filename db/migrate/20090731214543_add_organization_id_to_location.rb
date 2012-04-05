class AddOrganizationIdToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :organization_id, :integer
  end

  def self.down
    remove_column :locations, :organization_id
  end
end
