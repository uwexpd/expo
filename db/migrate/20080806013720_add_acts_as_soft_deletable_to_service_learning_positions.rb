class AddActsAsSoftDeletableToServiceLearningPositions < ActiveRecord::Migration
  def self.up
    ServiceLearningPosition::Deleted.create_table
  end

  def self.down
    ServiceLearningPosition::Deleted.drop_table
  end
end
