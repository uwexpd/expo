class CreateDepartmentExtras < ActiveRecord::Migration
  def self.up
    create_table :department_extras, :primary_key => :dept_code do |t|
      t.string :fixed_name
      t.string :chair_name
      t.string :chair_email
      t.string :chair_title

      t.timestamps
      t.integer :temp_num_students
    end
  end

  def self.down
    drop_table :department_extras
  end
end
