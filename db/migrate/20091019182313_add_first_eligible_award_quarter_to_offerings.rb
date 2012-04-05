class AddFirstEligibleAwardQuarterToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :first_eligible_award_quarter_id, :integer
  end

  def self.down
    remove_column :offerings, :first_eligible_award_quarter_id
  end
end
