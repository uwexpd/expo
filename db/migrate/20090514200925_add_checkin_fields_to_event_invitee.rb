class AddCheckinFieldsToEventInvitee < ActiveRecord::Migration
  def self.up
    add_column :event_invitees, :checkin_time, :datetime
    add_column :event_invitees, :checkin_notes, :text
  end

  def self.down
    remove_column :event_invitees, :checkin_notes
    remove_column :event_invitees, :checkin_time
  end
end
