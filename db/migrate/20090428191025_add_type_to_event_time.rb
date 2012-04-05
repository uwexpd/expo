class AddTypeToEventTime < ActiveRecord::Migration
  def self.up
    add_column :event_times, :type, :string
  end

  def self.down
    remove_column :event_times, :type
  end
end
