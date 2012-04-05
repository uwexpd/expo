class CreateEventStaffPositions < ActiveRecord::Migration
  def self.up
    create_table :event_staff_positions do |t|
      t.integer :event_id
      t.string :title
      t.integer :capacity
      t.text :description
      t.text :instructions
      t.integer :training_session_event_id
      t.text :restrictions
      t.boolean :require_all_shifts

      t.timestamps
    end
  end

  def self.down
    drop_table :event_staff_positions
  end
end
