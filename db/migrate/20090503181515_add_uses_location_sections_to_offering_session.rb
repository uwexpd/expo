class AddUsesLocationSectionsToOfferingSession < ActiveRecord::Migration
  def self.up
    add_column :offering_sessions, :uses_location_sections, :boolean
  end

  def self.down
    remove_column :offering_sessions, :uses_location_sections
  end
end
