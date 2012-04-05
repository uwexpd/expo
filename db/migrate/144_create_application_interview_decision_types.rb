class CreateApplicationInterviewDecisionTypes < ActiveRecord::Migration
  def self.up
    create_table :application_interview_decision_types do |t|
      t.string :title
      t.integer :application_status_type_id
      t.boolean :yes_option
      t.boolean :contingency_option

      t.timestamps
    end
  end

  def self.down
    drop_table :application_interview_decision_types
  end
end
