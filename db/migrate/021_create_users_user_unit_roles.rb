class CreateUsersUserUnitRoles < ActiveRecord::Migration
  def self.up
    create_table :users_user_unit_roles do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :users_user_unit_roles
  end
end
