class AddRestrictNumberOfAwardsToOfferingOtherAwardType < ActiveRecord::Migration
  def self.up
    add_column :offering_other_award_types, :restrict_number_of_awards_to, :integer
  end

  def self.down
    remove_column :offering_other_award_types, :restrict_number_of_awards_to
  end
end
