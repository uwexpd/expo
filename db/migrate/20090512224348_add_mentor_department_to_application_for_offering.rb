class AddMentorDepartmentToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :mentor_department, :string
  end

  def self.down
    remove_column :application_for_offerings, :mentor_department
  end
end
