class AddSelfPlacementChangeToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :volunteer_since, :date
    add_column :service_learning_positions, :paid, :boolean
    add_column :service_learning_positions, :religious, :boolean
    add_column :deleted_service_learning_positions, :volunteer_since, :date
    add_column :deleted_service_learning_positions, :paid, :boolean
    add_column :deleted_service_learning_positions, :religious, :boolean    
  end

  def self.down
    remove_column :service_learning_positions, :religious
    remove_column :service_learning_positions, :paid
    remove_column :service_learning_positions, :volunteer_since
    remove_column :deleted_service_learning_positions, :religious
    remove_column :deleted_service_learning_positions, :paid
    remove_column :deleted_service_learning_positions, :volunteer_since
  end
end
