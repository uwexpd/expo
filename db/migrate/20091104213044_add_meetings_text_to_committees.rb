class AddMeetingsTextToCommittees < ActiveRecord::Migration
  def self.up
    add_column :committees, :meetings_text, :text
  end

  def self.down
    remove_column :committees, :meetings_text
  end
end
