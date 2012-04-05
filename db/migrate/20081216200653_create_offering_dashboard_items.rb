class CreateOfferingDashboardItems < ActiveRecord::Migration
  def self.up
    create_table :offering_dashboard_items do |t|
      t.integer :offering_id
      t.integer :dashboard_item_id
      t.text :criteria

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_dashboard_items
  end
end
