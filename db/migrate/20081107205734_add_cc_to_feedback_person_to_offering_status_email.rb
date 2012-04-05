class AddCcToFeedbackPersonToOfferingStatusEmail < ActiveRecord::Migration
  def self.up
    add_column :offering_status_emails, :cc_to_feedback_person, :boolean
  end

  def self.down
    remove_column :offering_status_emails, :cc_to_feedback_person
  end
end
