class AddDepartmentAndOrganizationFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :other_department, :string
    add_column :people, :box_no, :string
  end

  def self.down
    remove_column :people, :box_no
    remove_column :people, :other_department
  end
end
