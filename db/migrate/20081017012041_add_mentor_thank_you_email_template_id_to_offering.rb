class AddMentorThankYouEmailTemplateIdToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :mentor_thank_you_email_template_id, :integer
  end

  def self.down
    remove_column :offerings, :mentor_thank_you_email_template_id
  end
end
