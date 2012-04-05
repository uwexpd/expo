class RemoveTypeFromPlacementAndPosition < ActiveRecord::Migration
  def self.up
    remove_column :service_learning_positions, :type
    remove_column :service_learning_placements, :type
  end

  def self.down
    add_column :service_learning_positions, :type, :string
    add_column :service_learning_placements, :type, :string
  end
end
