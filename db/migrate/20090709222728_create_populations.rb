class CreatePopulations < ActiveRecord::Migration
  def self.up
    create_table :populations do |t|
      t.string :title
      t.text :description
      t.string :populatable_type
      t.integer :populatable_id
      t.string :starting_set
      t.string :condition_operator
      t.string :access_level
      t.integer :creator_id
      t.integer :updater_id
      t.string :type
      t.timestamps
    end
    create_table :population_conditions do |t|
      t.integer :population_id
      t.string :attribute
      t.string :eval_method
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :population_conditions
    drop_table :populations
  end
end
