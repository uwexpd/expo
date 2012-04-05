class AddExtraCriteriaFieldsToOfferingDashboardItems < ActiveRecord::Migration
  def self.up
    add_column :offering_dashboard_items, :offering_application_type_id, :integer
    add_column :offering_dashboard_items, :status_lookup_method, :string
    add_column :offering_dashboard_items, :offering_status_id, :integer
    add_column :offering_dashboard_items, :disabled, :boolean
  end

  def self.down
    remove_column :offering_dashboard_items, :disabled
    remove_column :offering_dashboard_items, :application_status_type_id
    remove_column :offering_dashboard_items, :status_lookup_method
    remove_column :offering_dashboard_items, :offering_status_id
  end
end
