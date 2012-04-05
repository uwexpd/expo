class CreateOfferingApplicationTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_application_types do |t|
      t.integer :application_type_id
      t.integer :offering_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_application_types
  end
end
