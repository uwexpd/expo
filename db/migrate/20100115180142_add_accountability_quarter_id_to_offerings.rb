class AddAccountabilityQuarterIdToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :accountability_quarter_id, :integer
  end

  def self.down
    remove_column :offerings, :accountability_quarter_id
  end
end
