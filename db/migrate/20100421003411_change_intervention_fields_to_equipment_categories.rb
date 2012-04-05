class ChangeInterventionFieldsToEquipmentCategories < ActiveRecord::Migration
  def self.up
    rename_column :equipment_categories, :requires_intervention_before_next_checkout, :requires_staff_intervention_before_next_checkout
    add_column :equipment_categories, :requires_reimage_before_next_checkout, :boolean
    add_column :equipment, :hardware_address, :string
  end

  def self.down
    remove_column :equipment, :hardware_address
    remove_column :equipment_categories, :requires_reimage_before_next_checkout
    rename_column :equipment_categories, :requires_staff_intervention_before_next_checkout, :requires_intervention_before_next_checkout
  end
end
