class AddFeedbackFieldsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :feedback_meeting_date, :datetime
    add_column :application_for_offerings, :feedback_meeting_person_id, :integer
    add_column :application_for_offerings, :feedback_meeting_comments, :text
  end

  def self.down
    remove_column :application_for_offerings, :feedback_meeting_comments
    remove_column :application_for_offerings, :feedback_meeting_person_id
    remove_column :application_for_offerings, :feedback_meeting_date
  end
end
