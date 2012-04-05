class ChangeEmailTemplateAndAddToOffering < ActiveRecord::Migration
  def self.up
    rename_table :email_templates, :templates
  end

  def self.down
    rename_table :templates, :email_templates
  end
end
