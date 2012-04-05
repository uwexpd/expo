class AddPersonIdToEventInvitee < ActiveRecord::Migration
  def self.up
    add_column :event_invitees, :person_id, :integer
    EventInvitee.all.each{|i| i.update_attribute(:person_id, i.person.id) && print(".") rescue print("X") }
  end

  def self.down
    remove_column :event_invitees, :person_id
  end
end
