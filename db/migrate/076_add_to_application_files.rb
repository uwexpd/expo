class AddToApplicationFiles < ActiveRecord::Migration
  def self.up
    rename_column :application_files, :file_path, :file
    add_column :application_files, :file_mime_type, :string
    add_column :application_files, :file_filesize, :string
  end

  def self.down
    remove_column :application_files, :file_path_mime_type
    remove_column :application_files, :file_path_
    rename_column :application_files, :file, :file_path
  end
end
