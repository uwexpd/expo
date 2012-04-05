class AddEmailConfirmationToApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :email_confirmation, :string
  end

  def self.down
    remove_column :application_mentors, :email_confirmation
  end
end
