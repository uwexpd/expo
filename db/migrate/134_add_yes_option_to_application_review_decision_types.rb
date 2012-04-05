class AddYesOptionToApplicationReviewDecisionTypes < ActiveRecord::Migration
  def self.up
    add_column :application_review_decision_types, :yes_option, :boolean
  end

  def self.down
    remove_column :application_review_decision_types, :yes_option
  end
end
