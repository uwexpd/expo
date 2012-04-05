class AddTargetRecipientToEmailTemplates < ActiveRecord::Migration
  def self.up
    add_column :email_templates, :target_recipient, :string
  end

  def self.down
    remove_column :email_templates, :target_recipient
  end
end
