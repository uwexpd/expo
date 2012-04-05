class AddWorkedWithMentorToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :worked_with_mentor, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :worked_with_mentor
  end
end
