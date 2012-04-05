class AddTypeToServiceLearningPlacement < ActiveRecord::Migration
  def self.up
    add_column :service_learning_placements, :type, :string
    ServiceLearningPlacement::Deleted.update_columns
  end

  def self.down
    remove_column :service_learning_placements, :type
    ServiceLearningPlacement::Deleted.update_columns
  end
end
