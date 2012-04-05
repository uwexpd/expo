class CreateOrganizationContacts < ActiveRecord::Migration
  def self.up
    create_table :organization_contacts do |t|
      t.integer :person_id
      t.integer :organization_id
      t.boolean :americorps
      t.date :americorps_term_end_date
      t.boolean :service_learning_contact

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :organization_contacts
  end
end
