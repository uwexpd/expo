class AddInterviewTimesEmailSentAtToOfferingInterviewers < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :interview_times_email_sent_at, :datetime
  end

  def self.down
    remove_column :offering_interviewers, :interview_times_email_sent_at
  end
end
