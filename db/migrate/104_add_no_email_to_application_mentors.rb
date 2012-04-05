class AddNoEmailToApplicationMentors < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :no_email, :boolean
  end

  def self.down
    remove_column :application_mentors, :no_email
  end
end
