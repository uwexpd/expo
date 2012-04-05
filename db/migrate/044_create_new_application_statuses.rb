class CreateNewApplicationStatuses < ActiveRecord::Migration
  def self.up
    create_table :application_statuses do |t|
      t.integer :application_for_offering_id
      t.integer :application_status_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :application_statuses
  end
end
