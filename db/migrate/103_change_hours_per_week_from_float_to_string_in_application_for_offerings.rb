class ChangeHoursPerWeekFromFloatToStringInApplicationForOfferings < ActiveRecord::Migration
  def self.up
    change_column :application_for_offerings, :hours_per_week, :string
  end

  def self.down
    change_column :application_for_offerings, :hours_per_week, :float
  end
end
