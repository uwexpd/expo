class AddWorkshopEventIdToOfferingApplicationType < ActiveRecord::Migration
  def self.up
    add_column :offering_application_types, :workshop_event_id, :integer
  end

  def self.down
    remove_column :offering_application_types, :workshop_event_id
  end
end
