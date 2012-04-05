class AddCustomQueryToPopulations < ActiveRecord::Migration
  def self.up
    add_column :populations, :custom_query, :text
  end

  def self.down
    remove_column :populations, :custom_query
  end
end
