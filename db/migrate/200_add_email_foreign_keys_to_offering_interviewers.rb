class AddEmailForeignKeysToOfferingInterviewers < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :invite_email_contact_history_id, :integer
    add_column :offering_interviewers, :interview_times_email_contact_history_id, :integer
  end

  def self.down
    remove_column :offering_interviewers, :interview_times_email_contact_history_id
    remove_column :offering_interviewers, :invite_email_contact_history_id
  end
end
