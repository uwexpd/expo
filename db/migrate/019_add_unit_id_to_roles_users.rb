class AddUnitIdToRolesUsers < ActiveRecord::Migration
  def self.up
    add_column :roles_users, :unit_id, :integer
  end

  def self.down
    remove_column :roles_users, :unit_id
  end
end
