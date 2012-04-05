class AddInterviewDecisionToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :application_interview_decision_type_id, :integer
  end

  def self.down
    remove_column :application_for_offerings, :application_interview_decision_type_id
  end
end
