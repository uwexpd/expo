class CreateEquipmentReservations < ActiveRecord::Migration
  def self.up
    create_table :equipment_reservations do |t|
      t.integer :person_id
      t.datetime :policy_agreement_date
      t.text :project_description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :unit_id
      t.integer :approver_id
      t.datetime :approved_at
      t.datetime :checked_out_at
      t.string :checkout_id_verify
      t.integer :checkout_user_id
      t.datetime :checked_in_at
      t.integer :checkin_user_id
      t.boolean :checkin_ok
      t.text :checkin_notes
      t.boolean :submitted
      t.timestamps
    end
  end

  def self.down
    drop_table :equipment_reservations
  end
end
