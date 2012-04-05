class AddDescriptionToOfferingReviewCriterion < ActiveRecord::Migration
  def self.up
    add_column :offering_review_criterions, :description, :text
  end

  def self.down
    remove_column :offering_review_criterions, :description
  end
end
