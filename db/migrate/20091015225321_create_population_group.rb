class CreatePopulationGroup < ActiveRecord::Migration
  def self.up
    create_table :population_groups, :force => true do |t|
      t.string :title
      t.text :description
      t.integer :creator_id
      t.integer :updater_id
      t.string :access_level
      t.int :objects_count
      t.timestamps
    end
    create_table :population_group_members, :force => true do |t|
      t.integer :population_group_id
      t.integer :population_groupable_id
      t.string :population_groupable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :population_group_members
    drop_table :population_groups
  end
end
