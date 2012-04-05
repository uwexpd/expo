class AddConfirmFlagToPlacements < ActiveRecord::Migration
  def self.up
    add_column :service_learning_placements, :confirmed_at, :datetime
    add_column :service_learning_placements, :confirmation_history_id, :integer
    ServiceLearningPlacement::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_placements, :confirmed_at
    remove_column :service_learning_placements, :confirmation_history_id
    ServiceLearningPlacement::Deleted.update_columns
  end
end