class CreateAwardTypes < ActiveRecord::Migration
  def self.up
    create_table :award_types do |t|
      t.string :title
      t.integer :unit_id

      t.timestamps
    end
  end

  def self.down
    drop_table :award_types
  end
end
