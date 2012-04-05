class CreateChanges < ActiveRecord::Migration
  def self.up
    create_table :changes do |t|
      t.integer :change_loggable_id
      t.string :change_loggable_type
      t.text :changes
      t.integer :creator_id
      t.integer :updater_id
      t.integer :deleter_id
      t.string :action_type

      t.timestamps
    end
  end

  def self.down
    drop_table :changes
  end
end
