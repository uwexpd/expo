class AddIndexToServiceLearningPositions < ActiveRecord::Migration
  def self.up
    add_index :service_learning_positions, :organization_quarter_id
  end

  def self.down
    remove_index :service_learning_positions, :organization_quarter_id
  end
end
