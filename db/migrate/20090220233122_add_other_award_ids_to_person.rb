class AddOtherAwardIdsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :award_ids, :string
  end

  def self.down
    remove_column :people, :award_ids
  end
end
