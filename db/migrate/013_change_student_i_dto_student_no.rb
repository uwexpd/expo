class ChangeStudentIDtoStudentNo < ActiveRecord::Migration
  def self.up
    rename_column :people, :student_id, :student_no
  end

  def self.down
    rename_column :people, :student_no, :student_id
  end
end
