class AddAllowEarlyMentorSubmissionsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :allow_early_mentor_submissions, :boolean
  end

  def self.down
    remove_column :offerings, :allow_early_mentor_submissions
  end
end
