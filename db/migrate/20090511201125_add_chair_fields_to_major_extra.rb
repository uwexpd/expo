class AddChairFieldsToMajorExtra < ActiveRecord::Migration
  def self.up
    add_column :major_extras, :chair_name, :string
    add_column :major_extras, :chair_email, :string
    add_column :major_extras, :temp_num_students, :integer
  end

  def self.down
    remove_column :major_extras, :temp_num_students
    remove_column :major_extras, :chair_email
    remove_column :major_extras, :chair_name
  end
end
