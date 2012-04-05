class RemoveSoftDeadlineFromOffering < ActiveRecord::Migration
  def self.up
    remove_column :offerings, :hard_deadline
    rename_column :offerings, :soft_deadline, :deadline
  end

  def self.down
    add_column :offerings, :soft_deadline, :datetime
    rename_column :offerings, :deadline, :soft_deadline
  end
end
