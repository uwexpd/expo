class AddInterviewTimeLengthsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :interview_time_for_applicants, :integer
    add_column :offerings, :interview_time_for_interviewers, :integer
  end

  def self.down
    remove_column :offerings, :interview_time_for_interviewers
    remove_column :offerings, :interview_time_for_applicants
  end
end
