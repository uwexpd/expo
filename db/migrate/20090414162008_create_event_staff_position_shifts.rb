class CreateEventStaffPositionShifts < ActiveRecord::Migration
  def self.up
    create_table :event_staff_position_shifts do |t|
      t.integer :event_staff_position_id
      t.datetime :start_time
      t.datetime :end_time
      t.text :details

      t.timestamps
    end
  end

  def self.down
    drop_table :event_staff_position_shifts
  end
end
