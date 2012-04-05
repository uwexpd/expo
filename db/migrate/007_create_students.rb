class CreateStudents < ActiveRecord::Migration
  def self.up
    add_column :people, :student_id, :int
  end

  def self.down
    remove_column :people, :student_id
  end
end
