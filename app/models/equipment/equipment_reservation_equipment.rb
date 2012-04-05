# Models the join relationship between EquipmentReservation and Equipment
class EquipmentReservationEquipment < ActiveRecord::Base
  belongs_to :reservation, :class_name => "EquipmentReservation", :foreign_key => "equipment_reservation_id"
  belongs_to :equipment
  
  validates_presence_of :equipment_reservation_id, :equipment_id
  validates_uniqueness_of :equipment_id, :scope => :equipment_reservation_id
  
  
end
