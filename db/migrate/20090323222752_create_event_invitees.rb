class CreateEventInvitees < ActiveRecord::Migration
  def self.up
    create_table :event_invitees do |t|
      t.integer :event_time_id
      t.string :invitable_type
      t.integer :invitable_id
      t.boolean :attending
      t.text :rsvp_comments
      t.integer :number_of_guests

      t.timestamps
      t.userstamps
    end
  end

  def self.down
    drop_table :event_invitees
  end
end
