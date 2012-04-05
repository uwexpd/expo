class AddAcademicDepartmentToApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :academic_department, :string
  end

  def self.down
    remove_column :application_mentors, :academic_department
  end
end
