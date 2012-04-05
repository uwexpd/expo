class AddStudentNumberToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :student_no, :integer
  end

  def self.down
    remove_column :people, :student_no
  end
end
