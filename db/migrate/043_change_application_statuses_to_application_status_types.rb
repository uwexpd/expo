class ChangeApplicationStatusesToApplicationStatusTypes < ActiveRecord::Migration
  def self.up
    rename_table :application_statuses, :application_status_types
  end

  def self.down
    rename_table :application_status_types, :application_statuses
  end
end
