class AddOfferingIdToApplicationInterviewDecisionTypes < ActiveRecord::Migration
  def self.up
    add_column :application_interview_decision_types, :offering_id, :integer
  end

  def self.down
    remove_column :application_interview_decision_types, :offering_id
  end
end
