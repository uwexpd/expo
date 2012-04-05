class AddContingencyCheckinDateToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :contingency_checkin_date, :date
  end

  def self.down
    remove_column :application_for_offerings, :contingency_checkin_date
  end
end
