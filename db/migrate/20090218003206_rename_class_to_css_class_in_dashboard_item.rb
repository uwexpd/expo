class RenameClassToCssClassInDashboardItem < ActiveRecord::Migration
  def self.up
    rename_column :dashboard_items, :class, :css_class
  end

  def self.down
    rename_column :dashboard_items, :css_class, :class
  end
end
