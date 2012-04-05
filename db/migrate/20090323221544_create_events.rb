class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.text :description
      t.boolean :allow_multiple_times_per_attendee
      t.integer :capacity
      t.text :restrictions
      t.integer :offering_id
      t.integer :confirmation_email_template_id
      t.boolean :allow_guests
      t.integer :unit_id

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :events
  end
end
