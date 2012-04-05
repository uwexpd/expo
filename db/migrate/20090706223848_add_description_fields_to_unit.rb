class AddDescriptionFieldsToUnit < ActiveRecord::Migration
  def self.up
    add_column :units, :description, :text
    add_column :units, :home_url, :string
    add_column :units, :engage_url, :string
    add_column :units, :show_on_expo_welcome, :boolean
  end

  def self.down
    remove_column :units, :show_on_expo_welcome
    remove_column :units, :engage_url
    remove_column :units, :home_url
    remove_column :units, :description
  end
end
