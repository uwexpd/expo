class AddTitleAndFacilitatorToEventTime < ActiveRecord::Migration
  def self.up
    add_column :event_times, :title, :string
    add_column :event_times, :facilitator, :string
  end

  def self.down
    remove_column :event_times, :facilitator
    remove_column :event_times, :title
  end
end
