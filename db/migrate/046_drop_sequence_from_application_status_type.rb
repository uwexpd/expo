class DropSequenceFromApplicationStatusType < ActiveRecord::Migration
  def self.up
    remove_column :application_status_types, :sequence
  end

  def self.down
    add_column :application_status_types, :sequence, :integer
  end
end
