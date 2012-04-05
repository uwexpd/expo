class AddOfferingOtherAwardTypeToApplicationOtherAward < ActiveRecord::Migration
  def self.up
    add_column :application_other_awards, :offering_other_award_type_id, :integer
    add_column :application_other_awards, :award_quarter_id, :integer
  end

  def self.down
    remove_column :application_other_awards, :award_quarter_id
    remove_column :application_other_awards, :offering_other_award_type_id
  end
end
