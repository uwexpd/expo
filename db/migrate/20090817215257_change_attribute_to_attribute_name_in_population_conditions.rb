class ChangeAttributeToAttributeNameInPopulationConditions < ActiveRecord::Migration
  def self.up
    rename_column :population_conditions, :attribute, :attribute_name
  end

  def self.down
    rename_column :population_conditions, :attribute_name, :attribute
  end
end
