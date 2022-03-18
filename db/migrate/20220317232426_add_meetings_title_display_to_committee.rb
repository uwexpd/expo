class AddMeetingsTitleDisplayToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :meetings_alt_title, :string
  end

  def self.down
    remove_column :committees, :meetings_alt_title
  end
end
