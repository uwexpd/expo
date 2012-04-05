class CreateApplicationReviewerScores < ActiveRecord::Migration
  def self.up
    create_table :application_reviewer_scores do |t|
      t.integer :application_reviewer_id
      t.integer :offering_review_criterion_id
      t.integer :score
      t.text :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :application_reviewer_scores
  end
end
