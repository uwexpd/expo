class CreateDashboardItems < ActiveRecord::Migration
  def self.up
    create_table :dashboard_items do |t|
      t.string :title
      t.text :content
      t.string :icon
      t.string :class

      t.timestamps
    end
  end

  def self.down
    drop_table :dashboard_items
  end
end
