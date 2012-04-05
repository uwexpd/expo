class AddParentTimeAndExtraFieldsToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :extra_fields_to_display, :text
    add_column :event_times, :parent_time_id, :integer
  end

  def self.down
    remove_column :event_times, :parent_time_id
    remove_column :events, :extra_fields_to_display
  end
end
