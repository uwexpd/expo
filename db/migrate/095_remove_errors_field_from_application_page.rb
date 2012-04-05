class RemoveErrorsFieldFromApplicationPage < ActiveRecord::Migration
  def self.up
    remove_column :application_pages, :errors
  end

  def self.down
    add_column :application_pages, :errors, :text
  end
end
