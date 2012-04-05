class CreateOrganizationQuarterStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :organization_quarter_status_types do |t|
      t.string :title

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organization_quarter_status_types
  end
end
