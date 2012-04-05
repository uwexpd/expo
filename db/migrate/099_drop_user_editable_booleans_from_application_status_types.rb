class DropUserEditableBooleansFromApplicationStatusTypes < ActiveRecord::Migration
  def self.up
    remove_column :application_status_types, :disallow_user_edits
    remove_column :application_status_types, :disallow_all_edits
  end

  def self.down
    add_column :application_status_types, :disallow_user_edits, :boolean
    add_column :application_status_types, :disallow_all_edits, :boolean
  end
end
