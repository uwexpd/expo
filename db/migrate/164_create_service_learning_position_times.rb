class CreateServiceLearningPositionTimes < ActiveRecord::Migration
  def self.up
    create_table :service_learning_position_times do |t|
      t.integer :service_learning_position_id
      t.time :start_time
      t.time :end_time
      t.boolean :flexible
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_position_times
  end
end
