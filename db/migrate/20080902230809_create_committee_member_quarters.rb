class CreateCommitteeMemberQuarters < ActiveRecord::Migration
  def self.up
    create_table :committee_member_quarters do |t|
      t.integer :committee_member_id
      t.integer :committee_quarter_id
      t.boolean :active
      t.text :comment
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_member_quarters
  end
end
