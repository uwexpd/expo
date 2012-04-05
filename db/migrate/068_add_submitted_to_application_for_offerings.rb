class AddSubmittedToApplicationForOfferings < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :submitted, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :submitted
  end
end
