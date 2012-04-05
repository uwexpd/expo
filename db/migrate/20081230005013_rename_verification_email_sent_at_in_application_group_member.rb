class RenameVerificationEmailSentAtInApplicationGroupMember < ActiveRecord::Migration
  def self.up
    rename_column :application_group_members, :verification_email_sent_at, :validation_email_sent_at
  end

  def self.down
    rename_column :application_group_members, :validation_email_sent_at, :verification_email_sent_at
  end
end
