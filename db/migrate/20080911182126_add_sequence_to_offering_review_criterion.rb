class AddSequenceToOfferingReviewCriterion < ActiveRecord::Migration
  def self.up
    add_column :offering_review_criterions, :sequence, :integer
  end

  def self.down
    remove_column :offering_review_criterions, :sequence
  end
end
