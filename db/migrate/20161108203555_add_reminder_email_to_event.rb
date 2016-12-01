class AddReminderEmailToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :reminder_email_template_id, :integer
  end

  def self.down
    remove_column :events, :reminder_email_template_id
  end
end
