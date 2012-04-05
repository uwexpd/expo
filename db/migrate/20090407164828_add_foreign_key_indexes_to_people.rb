class AddForeignKeyIndexesToPeople < ActiveRecord::Migration
  def self.up
    add_index :people, :system_key
    add_index :people, :student_no
  end

  def self.down
    remove_index :people, :student_no
    remove_index :people, :system_key
  end
end
