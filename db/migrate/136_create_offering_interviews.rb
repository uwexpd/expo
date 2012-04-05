class CreateOfferingInterviews < ActiveRecord::Migration
  def self.up
    create_table :offering_interviews do |t|
      t.datetime :start_time
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_interviews
  end
end
