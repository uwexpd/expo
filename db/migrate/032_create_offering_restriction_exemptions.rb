class CreateOfferingRestrictionExemptions < ActiveRecord::Migration
  def self.up
    create_table :offering_restriction_exemptions do |t|
      t.integer :offering_restriction_id
      t.integer :person_id
      t.integer :note_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_restriction_exemptions
  end
end
