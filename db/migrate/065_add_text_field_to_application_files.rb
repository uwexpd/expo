class AddTextFieldToApplicationFiles < ActiveRecord::Migration
  def self.up
    add_column :application_files, :text_version, :text
  end

  def self.down
    remove_column :application_files, :text_version
  end
end
