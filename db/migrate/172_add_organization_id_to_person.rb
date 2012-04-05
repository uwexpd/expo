class AddOrganizationIdToPerson < ActiveRecord::Migration
  def self.up
#    add_column :people, :organization_id, :integer
############ removed this because we use the OrganizationContact table to manage this relationship
  end

  def self.down
#    remove_column :people, :organization_id
  end
end
