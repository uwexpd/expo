class AddAccessLevelToNote < ActiveRecord::Migration
  def self.up
    add_column :notes, :access_level, :string
    remove_column :notes, :private
    remove_column :notes, :personal
  end

  def self.down
    add_column :notes, :personal, :boolean
    add_column :notes, :private, :boolean
    remove_column :notes, :access_level
  end
end
