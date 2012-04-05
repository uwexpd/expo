class AddReviewCommitteeIdAndInterviewCommitteeIdToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :review_committee_id, :integer
    add_column :offerings, :interview_committee_id, :integer
  end

  def self.down
    remove_column :offerings, :interview_committee_id
    remove_column :offerings, :review_committee_id
  end
end
