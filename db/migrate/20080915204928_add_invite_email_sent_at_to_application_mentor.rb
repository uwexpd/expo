class AddInviteEmailSentAtToApplicationMentor < ActiveRecord::Migration
  def self.up
    add_column :application_mentors, :invite_email_sent_at, :datetime
  end

  def self.down
    remove_column :application_mentors, :invite_email_sent_at
  end
end
