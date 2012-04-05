class CreateApplicationReviewDecisionTypes < ActiveRecord::Migration
  def self.up
    create_table :application_review_decision_types do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :application_review_decision_types
  end
end
