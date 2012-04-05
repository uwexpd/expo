class AddDirectoryFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :department_id, :integer
    add_column :people, :email, :string
    add_column :people, :phone, :string
  end

  def self.down
    remove_column :people, :phone
    remove_column :people, :email
    remove_column :people, :department_id
  end
end
