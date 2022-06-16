class CreateServiceLearningPositionsSectorTypesLinks < ActiveRecord::Migration
  def self.up
    create_table :service_learning_positions_sector_types_links do |t|
      t.integer :service_learning_position_id
      t.integer :service_learning_positions_sector_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :service_learning_positions_sector_types_links
  end
end
