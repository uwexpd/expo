class AddReviewerFieldsToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :feedback_person_id, :integer
    add_column :application_for_offerings, :review_committee_notes, :text
    add_column :application_for_offerings, :interview_committee_notes, :text
  end

  def self.down
    remove_column :application_for_offerings, :interview_committee_notes
    remove_column :application_for_offerings, :review_committee_notes
    remove_column :application_for_offerings, :feedback_person_id
  end
end
