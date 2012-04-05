class CreateApplicationGuests < ActiveRecord::Migration
  def self.up
    create_table :application_guests do |t|
      t.integer :application_for_offering_id
      t.integer :group_member_id
      t.integer :application_mentor_id
      t.string :firstname
      t.string :lastname
      t.text :address_block
      t.boolean :uw_campus
      t.datetime :invitation_mailed_at

      t.timestamps
    end
  end

  def self.down
    drop_table :application_guests
  end
end
