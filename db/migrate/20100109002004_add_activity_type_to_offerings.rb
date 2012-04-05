class AddActivityTypeToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :activity_type_id, :integer
    remove_column :activities, :hours_per_week
    create_table :activity_quarters, :force => true do |t|
      t.integer :quarter_id
      t.decimal :hours
      t.string :hour_calculation_method
      t.timestamps
    end
  end

  def self.down
    drop_table :activity_quarters
    add_column :activities, :hours_per_week, :integer
    remove_column :offerings, :activity_type_id
  end
end
