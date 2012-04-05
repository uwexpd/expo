class AddUnitToOrgQuarter < ActiveRecord::Migration
  def self.up
    add_column :organization_quarters, :unit_id, :integer
  end

  def self.down
    remove_column :organization_quarters, :unit_id
  end
end
