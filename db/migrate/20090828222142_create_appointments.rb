class CreateAppointments < ActiveRecord::Migration
  def self.up
    create_table :appointments do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :staff_person_id
      t.integer :student_id
      t.datetime :check_in_time
      t.integer :unit_id
      t.text :notes
      t.text :follow_up_notes
      t.integer :previous_appointment_id
      t.boolean :drop_in
      t.string :contact_type
      t.string :type
      t.text :front_desk_notes
      t.string :source
      t.timestamps
    end
  end

  def self.down
    drop_table :appointments
  end
end
