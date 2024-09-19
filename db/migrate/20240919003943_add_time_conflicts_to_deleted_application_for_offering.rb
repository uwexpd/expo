class AddTimeConflictsToDeletedApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_for_offerings, :time_conflicts, :string
  end

  def self.down
    remove_column :deleted_application_for_offerings, :time_conflicts
  end
end
