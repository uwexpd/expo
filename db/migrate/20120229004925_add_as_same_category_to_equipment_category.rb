class AddAsSameCategoryToEquipmentCategory < ActiveRecord::Migration
  def self.up
    add_column :equipment_categories, :as_same_category, :string
  end

  def self.down
    remove_column :equipment_categories, :as_same_category
  end
end
