class CreateCommitteeMeetings < ActiveRecord::Migration
  def self.up
    create_table :committee_meetings do |t|
      t.integer :committee_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :title
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_meetings
  end
end
