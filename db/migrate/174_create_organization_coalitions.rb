class CreateOrganizationCoalitions < ActiveRecord::Migration
  def self.up
    create_table :organizations_coalitions do |t|
      t.integer :organization_id
      t.integer :coalition_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organizations_coalitions
  end
end
