class AddInterviewFeedbackPersonToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :interview_feedback_person_id, :integer
  end

  def self.down
    remove_column :application_for_offerings, :interview_feedback_person_id
  end
end
