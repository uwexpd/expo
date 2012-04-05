class CreateCoalitions < ActiveRecord::Migration
  def self.up
    create_table :coalitions do |t|
      t.string :title

      t.userstamps
      t.timestamps
    end
  end

  def self.down
    drop_table :coalitions
  end
end
