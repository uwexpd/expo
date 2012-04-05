class AddUsesInterviewsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :uses_interviews, :boolean
  end

  def self.down
    remove_column :offerings, :uses_interviews
  end
end
