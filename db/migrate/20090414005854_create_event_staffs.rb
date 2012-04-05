class CreateEventStaffs < ActiveRecord::Migration
  def self.up
    create_table :event_staffs do |t|
      t.integer :event_staff_position_shift_id
      t.integer :person_id
      t.text :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :event_staffs
  end
end
