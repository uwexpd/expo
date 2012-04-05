class CreateOrganizationQuarterStatuses < ActiveRecord::Migration
  def self.up
    create_table :organization_quarter_statuses do |t|
      t.integer :organization_quarter_id
      t.integer :organization_quarter_status_type_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organization_quarter_statuses
  end
end
