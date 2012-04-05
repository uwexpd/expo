class AddPlacementCounterCachesToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :filled_placements_count, :integer
    add_column :service_learning_positions, :total_placements_count, :integer
    add_column :service_learning_positions, :unallocated_placements_count, :integer
    
    ServiceLearningPosition.all.each do |slp|
      slp.update_placement_counts!
    end
    
    ServiceLearningPosition::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_positions, :unallocated_placements_count
    remove_column :service_learning_positions, :total_placements_count
    remove_column :service_learning_positions, :filled_placements_count
    
    ServiceLearningPosition::Deleted.update_columns
  end
end
