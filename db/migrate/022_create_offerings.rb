class CreateOfferings < ActiveRecord::Migration
  def self.up
    create_table :offerings do |t|
      t.string :name
      t.integer :unit_id
      t.datetime :open_date
      t.datetime :soft_deadline
      t.datetime :hard_deadline
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :offerings
  end
end
