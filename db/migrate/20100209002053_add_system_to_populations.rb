class AddSystemToPopulations < ActiveRecord::Migration
  def self.up
    add_column :populations, :system, :boolean
  end

  def self.down
    remove_column :populations, :system
  end
end
