class AddConditionsCountToPopulations < ActiveRecord::Migration
  def self.up
    add_column :populations, :conditions_counter, :integer
    for population in Population.all
      population.update_attribute(:conditions_counter, population.conditions.count)
    end
  end

  def self.down
    remove_column :populations, :conditions_counter
  end
end
