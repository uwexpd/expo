class CreateUserUnitRoles < ActiveRecord::Migration
  def self.up
    create_table :user_unit_roles do |t|
      t.integer :user_id, :role_id, :unit_id
    end

    drop_table :roles_users
    
  end

  def self.down
    drop_table :user_unit_roles
    
    create_table :roles_users , :id => false do |t|
      t.column :role_id, :integer
      t.column :user_id, :integer
    end
    
  end
end
