class AddStatusToEquipmentReservations < ActiveRecord::Migration
  def self.up
    add_column :equipment_reservations, :status, :string
  end

  def self.down
    remove_column :equipment_reservations, :status
  end
end
