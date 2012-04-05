class AddMaxQuartersAheadToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :max_quarters_ahead_for_awards, :integer
  end

  def self.down
    remove_column :offerings, :max_quarters_ahead_for_awards
  end
end
