class AddReviewCommentsToApplicationForOfferings < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :review_comments, :text
  end

  def self.down
    remove_column :application_for_offerings, :review_comments
  end
end
