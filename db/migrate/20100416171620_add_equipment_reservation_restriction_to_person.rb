class AddEquipmentReservationRestrictionToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :equipment_reservation_restriction_until, :datetime
  end

  def self.down
    remove_column :people, :equipment_reservation_restriction_until
  end
end
