class AddBufferDaysToEquipmentCategories < ActiveRecord::Migration
  def self.up
    add_column :equipment_categories, :buffer_days_between_checkouts, :integer, :default => 1
    add_column :equipment_categories, :checkout_instructions, :text
    add_column :equipment_categories, :checkin_instructions, :text
    add_column :equipment_categories, :requires_intervention_before_next_checkout, :boolean
  end

  def self.down
    remove_column :equipment_categories, :requires_intervention_before_next_checkout
    remove_column :equipment_categories, :checkin_instructions
    remove_column :equipment_categories, :checkout_instructions
    remove_column :equipment_categories, :buffer_days_between_checkouts
  end
end
