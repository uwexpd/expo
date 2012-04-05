class AddShowOnEquipmentReservationToUnit < ActiveRecord::Migration
  def self.up
    add_column :units, :show_on_equipment_reservation, :boolean
  end

  def self.down
    remove_column :units, :show_on_equipment_reservation
  end
end
