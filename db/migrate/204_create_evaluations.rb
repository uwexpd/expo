class CreateEvaluations < ActiveRecord::Migration
  def self.up
    create_table :evaluations do |t|
      t.integer :creator_id
      t.integer :updater_id
      t.integer :evaluatable_id
      t.string :evaluatable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluations
  end
end
