class AddIndexToPeople < ActiveRecord::Migration
  def self.up
    add_index :people, :email
  end

  def self.down
    remove_index :people, :email
  end
end
