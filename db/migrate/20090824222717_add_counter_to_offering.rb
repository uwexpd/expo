class AddCounterToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :application_for_offerings_count, :integer
    Offering.reset_column_information
    Offering.find(:all).each do |o|
      Offering.update_counters o.id, :application_for_offerings_count => o.application_for_offerings.count
    end
  end

  def self.down
    remove_column :offerings, :application_for_offerings_count
  end
end
