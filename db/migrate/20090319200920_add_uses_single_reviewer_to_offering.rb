class AddUsesSingleReviewerToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :uses_non_committee_review, :boolean
  end

  def self.down
    remove_column :offerings, :uses_non_committee_review
  end
end
