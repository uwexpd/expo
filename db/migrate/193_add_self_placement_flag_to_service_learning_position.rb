class AddSelfPlacementFlagToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :self_placement, :boolean
  end

  def self.down
    remove_column :service_learning_positions, :self_placement
  end
end
