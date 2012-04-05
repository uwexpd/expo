class CreateOfferingInterviewTimeblocks < ActiveRecord::Migration
  def self.up
    create_table :offering_interview_timeblocks do |t|
      t.integer :offering_id
      t.date :date
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_interview_timeblocks
  end
end
