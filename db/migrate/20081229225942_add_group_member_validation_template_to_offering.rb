class AddGroupMemberValidationTemplateToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :group_member_validation_email_template_id, :integer
  end

  def self.down
    remove_column :offerings, :group_member_validation_email_template_id
  end
end
