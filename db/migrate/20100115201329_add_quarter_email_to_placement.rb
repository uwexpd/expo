class AddQuarterEmailToPlacement < ActiveRecord::Migration
    def self.up
      add_column :service_learning_placements, :quarter_update_history_id, :integer
      ServiceLearningPlacement::Deleted.update_columns
    end

    def self.down
      remove_column :service_learning_placements, :quarter_update_history_id
      ServiceLearningPlacement::Deleted.update_columns
    end
  end
