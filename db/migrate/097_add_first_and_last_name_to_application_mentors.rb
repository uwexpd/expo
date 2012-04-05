class AddFirstAndLastNameToApplicationMentors < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :firstname, :string
    add_column :application_mentors, :lastname, :string
    add_column :application_mentors, :email, :string
  end

  def self.down
    remove_column :application_mentors, :email
    remove_column :application_mentors, :lastname
    remove_column :application_mentors, :firstname
  end
end
