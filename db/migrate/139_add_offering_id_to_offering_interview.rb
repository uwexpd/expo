class AddOfferingIdToOfferingInterview < ActiveRecord::Migration
  def self.up
    add_column :offering_interviews, :offering_id, :integer
  end

  def self.down
    remove_column :offering_interviews, :offering_id
  end
end
