class AddLettersSentAtFieldsToApplications < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :award_letter_sent_at, :datetime
    add_column :application_mentors, :mentor_letter_sent_at, :datetime
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
  end

  def self.down
    remove_column :application_mentors, :mentor_letter_sent_at
    remove_column :application_for_offerings, :award_letter_sent_at
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
  end
end
