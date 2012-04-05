class AddBusTripTimeToServiceLearningPosition < ActiveRecord::Migration
  def self.up
    add_column :service_learning_positions, :bus_trip_time, :integer
  end

  def self.down
    remove_column :service_learning_positions, :bus_trip_time
  end
end
