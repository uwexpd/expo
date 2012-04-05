class AddMentorDeadlineToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :mentor_deadline, :datetime
    add_column :offerings, :deny_mentor_access_after_mentor_deadline, :boolean
  end

  def self.down
    remove_column :offerings, :deny_mentor_access_after_mentor_deadline
    remove_column :offerings, :mentor_deadline
  end
end
