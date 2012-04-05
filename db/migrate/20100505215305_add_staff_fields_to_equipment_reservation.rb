class AddStaffFieldsToEquipmentReservation < ActiveRecord::Migration
  def self.up
    add_column :equipment_reservations, :staff, :boolean
    add_column :equipment_reservations, :program_hold, :boolean
  end

  def self.down
    remove_column :equipment_reservations, :program_hold
    remove_column :equipment_reservations, :staff
  end
end
