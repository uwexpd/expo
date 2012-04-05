class AddSubTimeIdToEventInvitee < ActiveRecord::Migration
  def self.up
    add_column :event_invitees, :sub_time_id, :integer
  end

  def self.down
    remove_column :event_invitees, :sub_time_id
  end
end
