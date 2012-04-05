class CreateQuarters < ActiveRecord::Migration
  def self.up
    create_table :quarters do |t|
      t.string :quarter
      t.integer :year
      t.date :first_day
      t.date :last_day
      t.date :registration_begins

      t.timestamps
    end
  end

  def self.down
    drop_table :quarters
  end
end
