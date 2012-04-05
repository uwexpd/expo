class AddOriginalFilenameToApplicationFile < ActiveRecord::Migration
  def self.up
    add_column :application_files, :original_filename, :string
  end

  def self.down
    remove_column :application_files, :original_filename
  end
end
