class AddSoftwareAndWarrantyFieldsToEquipment < ActiveRecord::Migration
  def self.up
    add_column :equipment, :included_accessories, :text
    add_column :equipment, :included_software, :text
    add_column :equipment, :replacement_fee, :float
    add_column :equipment, :inventory_number, :string
    add_column :equipment, :warranty_number, :string
    rename_column :equipment, :service_date, :warranty_expiration_date
  end

  def self.down
    rename_column :equipment, :warranty_expiration_date, :service_date
    remove_column :equipment, :warranty_number
    remove_column :equipment, :inventory_number
    remove_column :equipment, :replacement_fee
    remove_column :equipment, :included_software
    remove_column :equipment, :included_accessories
  end
end
