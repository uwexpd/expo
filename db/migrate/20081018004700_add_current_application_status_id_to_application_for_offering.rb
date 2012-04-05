class AddCurrentApplicationStatusIdToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :current_application_status_id, :integer
  end

  def self.down
    remove_column :application_for_offerings, :current_application_status_id
  end
end
