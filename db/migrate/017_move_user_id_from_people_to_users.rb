class MoveUserIdFromPeopleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :person_id, :integer
    remove_column :people, :user_id
  end

  def self.down
    remove_column :users, :person_id
    add_column :people, :user_id, :integer
  end
end
