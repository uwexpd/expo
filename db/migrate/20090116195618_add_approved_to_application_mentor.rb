class AddApprovedToApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :approval_response, :string
    add_column :application_mentors, :approval_comments, :text
    add_column :application_mentors, :approval_at, :datetime
  end

  def self.down
    remove_column :application_mentors, :approval_response
    remove_column :application_mentors, :approval_comments
    remove_column :application_mentors, :approval_at
  end
end
