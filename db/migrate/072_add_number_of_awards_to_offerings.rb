class AddNumberOfAwardsToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :number_of_awards, :integer
    add_column :offerings, :default_award_amount, :float
  end

  def self.down
    remove_column :offerings, :default_award_amount
    remove_column :offerings, :number_of_awards
  end
end
