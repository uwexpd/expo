class AddAlternateMentorTitleToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :alternate_mentor_title, :string
    add_column :offerings, :ask_for_mentor_relationship, :boolean
    add_column :offerings, :ask_for_mentor_title, :boolean
    add_column :application_mentors, :title, :string
    add_column :application_mentors, :relationship, :string
  end

  def self.down
    remove_column :application_mentors, :relationship
    remove_column :application_mentors, :title
    remove_column :offerings, :ask_for_mentor_title
    remove_column :offerings, :ask_for_mentor_relationship
    remove_column :offerings, :alternate_mentor_title
  end
end
