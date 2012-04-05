class CreateOfferingRestrictionTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_restriction_types do |t|
      t.string :name
      t.string :description
      t.text :error_message
      t.string :method_to_call

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_restriction_types
  end
end
