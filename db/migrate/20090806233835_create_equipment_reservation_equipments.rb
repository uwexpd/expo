class CreateEquipmentReservationEquipments < ActiveRecord::Migration
  def self.up
    create_table :equipment_reservation_equipments do |t|
      t.integer :equipment_reservation_id
      t.integer :equipment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :equipment_reservation_equipments
  end
end
