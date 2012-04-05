class AddInactiveToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :inactive, :boolean
  end

  def self.down
    remove_column :organizations, :inactive
  end
end
