class AddApprovedToServiceLearningPositions < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :approved, :boolean
  end

  def self.down
    remove_column :service_learning_positions, :approved
  end
end
