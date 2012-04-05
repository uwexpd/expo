class AddMoreParametersToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :min_number_of_awards, :integer
    add_column :offerings, :max_number_of_awards, :integer
    add_column :offerings, :min_number_of_mentors, :integer
  end

  def self.down
    remove_column :offerings, :min_number_of_mentors
    remove_column :offerings, :max_number_of_awards
    remove_column :offerings, :min_number_of_awards
  end
end
