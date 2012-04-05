class AddFinalizedToApplicationReviewer < ActiveRecord::Migration
  def self.up
    add_column :application_reviewers, :finalized, :boolean
  end

  def self.down
    remove_column :application_reviewers, :finalized
  end
end
