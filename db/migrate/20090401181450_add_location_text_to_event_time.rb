class AddLocationTextToEventTime < ActiveRecord::Migration
  def self.up
    add_column :event_times, :location_text, :string
  end

  def self.down
    remove_column :event_times, :location_text
  end
end
