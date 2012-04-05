class RemoveApplicationStatusFromApplicationForOfferings < ActiveRecord::Migration
  def self.up
    remove_column :application_for_offerings, :application_status_id
    remove_column :application_for_offerings, :submitted
  end

  def self.down
    add_column :application_for_offerings, :application_status_id
    add_column :application_for_offerings, :submitted, :integer
  end
end
