class AddIndexesToStudentRelatedTables < ActiveRecord::Migration
  def self.up
    add_index :application_for_offerings, :person_id
    add_index :appointments, :staff_person_id
    add_index :appointments, :student_id
    add_index :appointments, :previous_appointment_id
    add_index :notes, [:notable_id, :notable_type], :name => "notable_index"
  end

  def self.down
    remove_index :notes, :name => :notable_index
    remove_index :appointments, :previous_appointment_id
    remove_index :appointments, :student_id
    remove_index :appointments, :staff_person_id
    remove_index :application_for_offerings, :person_id
  end
end
