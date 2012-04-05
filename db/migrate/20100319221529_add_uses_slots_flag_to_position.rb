class AddUsesSlotsFlagToPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :use_slots, :boolean
    ServiceLearningPosition::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_positions, :use_slots
    ServiceLearningPosition::Deleted.update_columns
  end
end
