class CreateCommitteeMembers < ActiveRecord::Migration
  def self.up
    create_table :committee_members do |t|
      t.integer :committee_id
      t.integer :person_id
      t.integer :committee_member_type_id
      t.string :expertise
      t.string :website_url
      t.integer :recommender_id
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_members
  end
end
