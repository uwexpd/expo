class AddApplicationForOfferingIdToApplicationOtherAwards < ActiveRecord::Migration
  def self.up
    add_column :application_other_awards, :application_for_offering_id, :integer
  end

  def self.down
    remove_column :application_other_awards, :application_for_offering_id
  end
end
