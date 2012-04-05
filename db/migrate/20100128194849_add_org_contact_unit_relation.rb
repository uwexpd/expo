class AddOrgContactUnitRelation < ActiveRecord::Migration
  def self.up
    create_table :organization_contact_units do |t|
      t.integer :organization_contact_id, :null => false
      t.integer :unit_id, :null => false
      t.boolean :primary_contact
    end
  end

  def self.down
    drop_table :organization_contact_units
  end
end
