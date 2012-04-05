class CreateOfferingAwardTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_award_types do |t|
      t.integer :offering_id
      t.integer :award_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_award_types
  end
end
