class AddDeletedToPopulation < ActiveRecord::Migration
  def self.up
    add_column :populations, :deleted, :boolean
    add_column :populations, :deleted_at, :datetime
  end

  def self.down
    remove_column :populations, :deleted_at
    remove_column :populations, :deleted
  end
end
