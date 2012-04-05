class CreateInterviewAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :interview_availabilities do |t|
      t.integer :offering_interview_timeblock_id
      t.integer :application_for_offering_id
      t.integer :offering_interviewer_id
      t.time :time

      t.timestamps
    end
  end

  def self.down
    drop_table :interview_availabilities
  end
end
