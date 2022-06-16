class CreateServiceLearningPositionsSectorTypes < ActiveRecord::Migration
  def self.up
    create_table :service_learning_positions_sector_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :service_learning_positions_sector_types
  end
end
