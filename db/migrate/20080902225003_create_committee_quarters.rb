class CreateCommitteeQuarters < ActiveRecord::Migration
  def self.up
    create_table :committee_quarters do |t|
      t.integer :committee_id
      t.integer :quarter_id
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_quarters
  end
end
