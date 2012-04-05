class CreateCommitteeMemberMeetings < ActiveRecord::Migration
  def self.up
    create_table :committee_member_meetings do |t|
      t.integer :committee_member_id
      t.integer :committee_meeting_id
      t.boolean :attending
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_member_meetings
  end
end
