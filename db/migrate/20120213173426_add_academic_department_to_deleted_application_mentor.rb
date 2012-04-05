class AddAcademicDepartmentToDeletedApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_mentors, :academic_department, :string
  end

  def self.down
    remove_column :deleted_application_mentors, :academic_department
  end
end
