class AddIndexesToApplicationReviewerScores < ActiveRecord::Migration
  def self.up
    add_index :application_reviewer_scores, :application_reviewer_id
    add_index :application_reviewer_scores, :offering_review_criterion_id, :name => 'offering_review_criterion_index'
  end

  def self.down
    remove_index :application_reviewer_scores, :offering_review_criterion_id
    remove_index :application_reviewer_scores, :application_reviewer_id
  end
end
