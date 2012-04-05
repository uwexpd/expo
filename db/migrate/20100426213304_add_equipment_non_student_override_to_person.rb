class AddEquipmentNonStudentOverrideToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :equipment_reservation_non_student_override_until, :datetime
  end

  def self.down
    remove_column :people, :equipment_reservation_non_student_override_until
  end
end
