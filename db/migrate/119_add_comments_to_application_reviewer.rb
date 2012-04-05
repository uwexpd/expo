class AddCommentsToApplicationReviewer < ActiveRecord::Migration
  def self.up
    add_column :application_reviewers, :comments, :text
  end

  def self.down
    remove_column :application_reviewers, :comments
  end
end
