class UpdateFieldsForNewUploadColumn < ActiveRecord::Migration
  def self.up
    rename_column :application_files, :file_mime_type, :file_content_type
    rename_column :application_files, :file_filesize, :file_size
    rename_column :application_mentors, :letter_mime_type, :letter_content_type
    rename_column :application_mentors, :letter_filesize, :letter_size
  end

  def self.down
    rename_column :application_files, :file_size, :file_filesize
    rename_column :application_files, :file_content_type, :file_mime_type
    rename_column :application_mentors, :letter_content_type, :letter_mime_type
    rename_column :application_mentors, :letter_size, :letter_filesize
  end
end
