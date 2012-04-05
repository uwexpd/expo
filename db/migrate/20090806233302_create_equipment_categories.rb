class CreateEquipmentCategories < ActiveRecord::Migration
  def self.up
    create_table :equipment_categories do |t|
      t.string :title
      t.text :description
      t.integer :max_checkout_days
      t.text :staff_instructions
      t.string :picture
      t.integer :max_items_per_checkout, :default => 1

      t.timestamps
    end
  end

  def self.down
    drop_table :equipment_categories
  end
end
