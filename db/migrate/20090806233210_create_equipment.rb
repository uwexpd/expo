class CreateEquipment < ActiveRecord::Migration
  def self.up
    create_table :equipment do |t|
      t.string :tag
      t.string :title
      t.integer :equipment_category_id
      t.datetime :service_date
      t.boolean :ready_for_checkout
      t.string :local_picture
      t.text :description
      t.boolean :staff_only
      t.text :special_instructions
      t.datetime :purchase_date
      t.string :serial_number

      t.timestamps
    end
  end

  def self.down
    drop_table :equipment
  end
end
