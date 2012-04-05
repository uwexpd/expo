class CreateCommitteeMemberTypes < ActiveRecord::Migration
  def self.up
    create_table :committee_member_types do |t|
      t.integer :committee_id
      t.string :name
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_member_types
  end
end
