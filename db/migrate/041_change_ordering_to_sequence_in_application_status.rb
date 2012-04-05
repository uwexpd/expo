class ChangeOrderingToSequenceInApplicationStatus < ActiveRecord::Migration
  def self.up
    rename_column :application_statuses, :ordering, :sequence
  end

  def self.down
    rename_column :application_statuses, :sequence, :ordering
  end
end
