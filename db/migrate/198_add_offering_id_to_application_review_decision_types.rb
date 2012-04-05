class AddOfferingIdToApplicationReviewDecisionTypes < ActiveRecord::Migration
  def self.up
    add_column :application_review_decision_types, :offering_id, :integer
  end

  def self.down
    remove_column :application_review_decision_types, :offering_id
  end
end
