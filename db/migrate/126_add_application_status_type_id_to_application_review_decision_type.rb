class AddApplicationStatusTypeIdToApplicationReviewDecisionType < ActiveRecord::Migration
  def self.up
    add_column :application_review_decision_types, :application_status_type_id, :integer
  end

  def self.down
    remove_column :application_review_decision_types, :application_status_type_id
  end
end
