class CreateUserUnitRoleAuthorizations < ActiveRecord::Migration
  def self.up
    create_table :user_unit_role_authorizations do |t|
      t.integer :user_unit_role_id
      t.string :authorizable_type
      t.integer :authorizable_id
      t.integer :creator_id
      t.integer :updater_id
      t.integer :deleter_id
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :user_unit_role_authorizations
  end
end
