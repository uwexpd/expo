class ChangeApplicationStatusIdToApplicationStatusTypeInOfferingStatuses < ActiveRecord::Migration
  def self.up
    rename_column :offering_statuses, :application_status_id, :application_status_type_id
  end

  def self.down
    rename_column :offering_statuses, :application_status_type_id, :application_status_id
  end
end
