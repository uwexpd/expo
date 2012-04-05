class AddAccountabilityFieldsToActivities < ActiveRecord::Migration
  def self.up
    remove_column :activities, :object1_id
    remove_column :activities, :object2_id
    remove_column :activities, :note_id
    add_column :activities, :faculty_id, :integer
    add_column :activities, :department_id, :integer
    add_column :activities, :title, :string
    add_column :activities, :quarter_id, :integer
    add_column :activities, :ts_year, :integer
    add_column :activities, :ts_quarter, :integer
    add_column :activities, :course_branch, :integer
    add_column :activities, :course_no, :integer
    add_column :activities, :dept_abbrev, :string
    add_column :activities, :section_id, :string
    add_column :activities, :start_date, :date
    add_column :activities, :end_date, :date
    add_column :activities, :hours_per_week, :integer
    add_column :activities, :number_of_hours, :integer
    add_column :activities, :type, :string
    add_column :activities, :activity_course_id, :integer
    add_column :activities, :activity_type_id, :integer
  end

  def self.down
    remove_column :activities, :activity_type_id
    remove_column :activities, :activity_course_id
    remove_column :activities, :type
    remove_column :activities, :number_of_hours
    remove_column :activities, :hours_per_week
    remove_column :activities, :end_date
    remove_column :activities, :start_date
    remove_column :activities, :section_id
    remove_column :activities, :dept_abbrev
    remove_column :activities, :course_no
    remove_column :activities, :course_branch
    remove_column :activities, :ts_quarter
    remove_column :activities, :ts_year
    remove_column :activities, :quarter_id
    remove_column :activities, :title
    remove_column :activities, :department_id
    remove_column :activities, :faculty_id
    add_column :activities, :note_id, :integer
    add_column :activities, :object2_id, :integer
    add_column :activities, :object1_id, :integer
  end
end
