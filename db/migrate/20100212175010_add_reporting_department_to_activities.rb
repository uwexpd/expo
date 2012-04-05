class AddReportingDepartmentToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :reporting_department_id, :integer
    add_column :activities, :reporting_department_name, :string
  end

  def self.down
    remove_column :activities, :reporting_department_name
    remove_column :activities, :reporting_department_id
  end
end
