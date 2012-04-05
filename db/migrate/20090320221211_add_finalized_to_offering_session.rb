class AddFinalizedToOfferingSession < ActiveRecord::Migration
  def self.up
    add_column :offering_sessions, :finalized, :boolean
    add_column :offering_sessions, :finalized_date, :datetime
  end

  def self.down
    remove_column :offering_sessions, :finalized_date
    remove_column :offering_sessions, :finalized
  end
end
