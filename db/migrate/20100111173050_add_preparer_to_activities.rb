class AddPreparerToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :preparer_uw_netid, :string
    add_column :activities, :notes, :string
    add_column :activities, :hours_per_week, :decimal
  end

  def self.down
    remove_column :activities, :hours_per_week
    remove_column :activities, :notes
    remove_column :activities, :preparer_uw_netid
  end
end
