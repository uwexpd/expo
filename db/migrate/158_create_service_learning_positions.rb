class CreateServiceLearningPositions < ActiveRecord::Migration
  def self.up
    create_table :service_learning_positions do |t|
      t.string :title
      t.integer :organization_quarter_id
      t.integer :location_id
      t.text :description
      t.string :age_requirement
      t.string :duration_requirement
      t.text :alternate_transportation
      t.integer :previous_service_learning_position_id
      t.integer :supervisor_person_id
      t.text :time_notes
      t.integer :service_learning_orientation_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :service_learning_positions
  end
end
