class AddExtraContactFieldsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :salutation, :string
    add_column :people, :extension, :integer
    add_column :people, :address1, :string
    add_column :people, :address2, :string
    add_column :people, :address3, :string
    add_column :people, :city, :string
    add_column :people, :state, :string
    add_column :people, :zip, :string
    add_column :people, :organization, :string
    add_column :people, :title, :string
  end

  def self.down
    remove_column :people, :title
    remove_column :people, :organization
    remove_column :people, :zip
    remove_column :people, :state
    remove_column :people, :city
    remove_column :people, :address3
    remove_column :people, :address2
    remove_column :people, :address1
    remove_column :people, :extension
    remove_column :people, :salutation
  end
end
