class AddFilePathToApplicationFiles < ActiveRecord::Migration
  def self.up
    add_column :application_files, :file_path, :string
  end

  def self.down
    remove_column :application_files, :file_path
  end
end
