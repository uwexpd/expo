class AddCommitteeMemberIdToApplicationReviewer < ActiveRecord::Migration
  def self.up
    add_column :application_reviewers, :committee_member_id, :integer
  end

  def self.down
    remove_column :application_reviewers, :committee_member_id
  end
end
