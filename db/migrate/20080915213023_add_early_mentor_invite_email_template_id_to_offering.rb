class AddEarlyMentorInviteEmailTemplateIdToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :early_mentor_invite_email_template_id, :integer
  end

  def self.down
    remove_column :offerings, :early_mentor_invite_email_template_id
  end
end
