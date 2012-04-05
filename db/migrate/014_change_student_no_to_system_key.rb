class ChangeStudentNoToSystemKey < ActiveRecord::Migration
  def self.up
    rename_column :people, :student_no, :system_key
  end

  def self.down
    rename_column :people, :system_key, :student_no
  end
end
