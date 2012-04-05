class AddDisallowEditsFieldsToApplicationStatusType < ActiveRecord::Migration
  def self.up
    add_column :application_status_types, :disallow_user_edits, :boolean
    add_column :application_status_types, :disallow_all_edits, :boolean
  end

  def self.down
    remove_column :application_status_types, :disallow_user_edits
    remove_column :application_status_types, :disallow_all_edits
  end
end
