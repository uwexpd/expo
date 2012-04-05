class CreateServiceLearningOrientations < ActiveRecord::Migration
  def self.up
    create_table :service_learning_orientations do |t|
      t.datetime :start_time
      t.integer :location_id
      t.boolean :flexible

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_orientations
  end
end
