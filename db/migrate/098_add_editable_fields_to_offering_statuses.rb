class AddEditableFieldsToOfferingStatuses < ActiveRecord::Migration
  def self.up
    add_column :offering_statuses, :disallow_user_edits, :boolean
    add_column :offering_statuses, :disallow_all_edits, :boolean
  end

  def self.down
    remove_column :offering_statuses, :disallow_all_edits
    remove_column :offering_statuses, :disallow_user_edits
  end
end
