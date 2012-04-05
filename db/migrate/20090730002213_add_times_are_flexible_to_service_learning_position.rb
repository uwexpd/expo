class AddTimesAreFlexibleToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :times_are_flexible, :boolean
  end

  def self.down
    remove_column :service_learning_positions, :times_are_flexible
  end
end
