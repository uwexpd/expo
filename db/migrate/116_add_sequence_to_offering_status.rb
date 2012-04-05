class AddSequenceToOfferingStatus < ActiveRecord::Migration
  def self.up
    add_column :offering_statuses, :sequence, :integer
  end

  def self.down
    remove_column :offering_statuses, :sequence
  end
end
