class CreateEventTimes < ActiveRecord::Migration
  def self.up
    create_table :event_times do |t|
      t.integer :event_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :location_id
      t.integer :capacity
      t.text :notes

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :event_times
  end
end
