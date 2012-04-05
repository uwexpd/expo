class AddShowLocationInfoInCheckinToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :show_application_location_in_checkin, :boolean
  end

  def self.down
    remove_column :events, :show_application_location_in_checkin
  end
end
