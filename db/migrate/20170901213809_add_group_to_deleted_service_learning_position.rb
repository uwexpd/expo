class AddGroupToDeletedServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :deleted_service_learning_positions, :group_ok, :boolean
  end

  def self.down
    remove_column :deleted_service_learning_positions, :group_ok
  end
end
