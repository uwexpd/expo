class AddMobileCheckinToEventInvitee < ActiveRecord::Migration
  def self.up
    add_column :event_invitees, :mobile_checkin, :boolean
  end

  def self.down
    remove_column :event_invitees, :mobile_checkin
  end
end
