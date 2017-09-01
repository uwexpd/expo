class AddGroupToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :group_ok, :boolean
  end

  def self.down
    remove_column :service_learning_positions, :group_ok
  end
end
