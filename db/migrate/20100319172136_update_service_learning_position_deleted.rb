class UpdateServiceLearningPositionDeleted < ActiveRecord::Migration
    def self.up
      ServiceLearningPosition::Deleted.update_columns
    end

    def self.down
      ServiceLearningPosition::Deleted.update_columns
    end
  end
