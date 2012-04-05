class CreateApplicationGroupMembers < ActiveRecord::Migration
  def self.up
    create_table :application_group_members do |t|
      t.integer :application_for_offering_id
      t.integer :person_id
      t.boolean :verified
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :application_group_members
  end
end
