class AddAdvisingInfoQuestionsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :attended_info_session, :boolean
    add_column :application_for_offerings, :attended_advising_appointment, :boolean
    add_column :application_for_offerings, :attended_feedback_appointment, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :attended_feedback_appointment
    remove_column :application_for_offerings, :attended_advising_appointment
    remove_column :application_for_offerings, :attended_info_session
  end
end
