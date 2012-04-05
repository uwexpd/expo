class AddStudentFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :institution_id, :integer
    add_column :people, :major_1, :string
    add_column :people, :major_2, :string
    add_column :people, :major_3, :string
    add_column :people, :class_standing_id, :integer
  end

  def self.down
    remove_column :people, :class_standing_id
    remove_column :people, :major_3
    remove_column :people, :major_2
    remove_column :people, :major_1
    remove_column :people, :institution_id
  end
end
