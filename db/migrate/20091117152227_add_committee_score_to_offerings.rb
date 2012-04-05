class AddCommitteeScoreToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :review_committee_submits_committee_score, :boolean
    add_column :offerings, :interview_committee_submits_committee_score, :boolean
    add_column :application_reviewers, :committee_score, :boolean
  end

  def self.down
    remove_column :application_reviewers, :committee_score
    remove_column :offerings, :interview_committee_submits_committee_score
    remove_column :offerings, :review_committee_submits_committee_score
  end
end
