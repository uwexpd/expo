class AddOfferingReviewerToApplicationReviewer < ActiveRecord::Migration
  def self.up
    add_column :application_reviewers, :offering_reviewer_id, :integer
    remove_column :application_reviewers, :person_id
  end

  def self.down
    remove_column :application_reviewers, :offering_reviewer_id
    add_column :application_reviewers, :person_id, :integer
  end
end
