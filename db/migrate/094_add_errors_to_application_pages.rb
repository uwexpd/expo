class AddErrorsToApplicationPages < ActiveRecord::Migration
  def self.up
    add_column :application_pages, :errors, :text
  end

  def self.down
    remove_column :application_pages, :errors
  end
end
