class AddLocationToCommitteeMeeting < ActiveRecord::Migration
  def self.up
    add_column :committee_meetings, :location, :string
  end

  def self.down
    remove_column :committee_meetings, :location
  end
end
