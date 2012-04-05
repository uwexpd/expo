class ChangeFacultyIdToFacultyUwNetid < ActiveRecord::Migration
  def self.up
    remove_column :activities, :faculty_id
    add_column :activities, :faculty_uw_netid, :string
    add_column :activities, :department_name, :string
    add_column :activities, :faculty_name, :string
    add_column :activities, :system_key, :integer
    remove_column :activity_quarters, :hours
    remove_column :activity_quarters, :hour_calculation_method
    add_column :activity_quarters, :hours_per_week, :decimal
    add_column :activity_quarters, :number_of_hours, :decimal
    remove_column :activities, :number_of_hours
    add_column :activities, :number_of_hours, :decimal
    add_column :activity_quarters, :activity_id, :integer
  end

  def self.down
    remove_column :activity_quarters, :activity_id
    remove_column :activities, :number_of_hours
    add_column :activities, :number_of_hours, :integer
    remove_column :activity_quarters, :number_of_hours
    remove_column :activity_quarters, :hours_per_week
    add_column :activity_quarters, :hour_calculation_method, :string
    add_column :activity_quarters, :hours, :integer
    remove_column :activities, :system_key
    remove_column :activities, :faculty_name
    remove_column :activities, :department_name
    add_column :activities, :faculty_id, :integer
    remove_column :activities, :faculty_uw_netid
  end
end
