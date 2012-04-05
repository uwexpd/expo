class CreateOfferingRestrictions < ActiveRecord::Migration
  def self.up
    create_table :offering_restrictions do |t|
      t.integer :offering_id
      t.integer :offering_restriction_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_restrictions
  end
end
