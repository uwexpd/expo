class ChangeDecimalsToFloatsInActivities < ActiveRecord::Migration
  def self.up
    change_column :activities, :hours_per_week, :decimal, :precision => 10, :scale => 2
    change_column :activities, :number_of_hours, :decimal, :precision => 10, :scale => 2
    change_column :activity_quarters, :hours_per_week, :decimal, :precision => 10, :scale => 2
    change_column :activity_quarters, :number_of_hours, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    change_column :activities, :hours_per_week, :decimal, :precision => 10, :scale => 0
    change_column :activities, :number_of_hours, :decimal, :precision => 10, :scale => 0
    change_column :activity_quarters, :hours_per_week, :decimal, :precision => 10, :scale => 0
    change_column :activity_quarters, :number_of_hours, :decimal, :precision => 10, :scale => 0
  end
end
