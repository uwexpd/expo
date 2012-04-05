class CreateOfferingSessions < ActiveRecord::Migration
  def self.up
    create_table :offering_sessions do |t|
      t.integer :offering_id
      t.string :title
      t.integer :moderator_id
      t.text :moderator_comments
      t.string :location
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_sessions
  end
end
