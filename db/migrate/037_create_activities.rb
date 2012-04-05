class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :object1_id
      t.integer :object2_id
      t.integer :note_id

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
