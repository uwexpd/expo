class CreateServiceLearningPlacements < ActiveRecord::Migration
  def self.up
    create_table :service_learning_placements do |t|
      t.integer :person_id
      t.integer :service_learning_position_id
      t.integer :service_learning_course_id
      t.datetime :waiver_date
      t.string :waiver_signature

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_placements
  end
end
