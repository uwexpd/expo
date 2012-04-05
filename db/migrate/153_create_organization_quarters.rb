class CreateOrganizationQuarters < ActiveRecord::Migration
  def self.up
    create_table :organization_quarters do |t|
      t.integer :organization_id
      t.integer :quarter_id
      t.boolean :active
      t.integer :staff_contact_person_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organization_quarters
  end
end
