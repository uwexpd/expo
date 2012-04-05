class AddLetterFieldsToApplicationMentors < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :letter, :string
    add_column :application_mentors, :letter_mime_type, :string
    add_column :application_mentors, :letter_filesize, :string
  end

  def self.down
    remove_column :application_mentors, :letter_filesize
    remove_column :application_mentors, :letter_mime_type
    remove_column :application_mentors, :letter
  end
end
