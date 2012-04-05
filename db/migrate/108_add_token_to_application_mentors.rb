class AddTokenToApplicationMentors < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :token, :string
  end

  def self.down
    remove_column :application_mentors, :token
  end
end
