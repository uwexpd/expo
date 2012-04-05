class AddReplacementRecommendationToCommitteeMember < ActiveRecord::Migration
  def self.up
    add_column :committee_members, :replacement_recommendation, :text
  end

  def self.down
    remove_column :committee_members, :replacement_recommendation
  end
end
