class AddApplicationMentorTypeToApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :application_mentor_type_id, :integer
  end

  def self.down
    remove_column :application_mentors, :application_mentor_type_id
  end
end
