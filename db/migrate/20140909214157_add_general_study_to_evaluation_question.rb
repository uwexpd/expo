class AddGeneralStudyToEvaluationQuestion < ActiveRecord::Migration
  def self.up
    add_column :evaluation_questions, :general_study, :boolean
  end

  def self.down
    remove_column :evaluation_questions, :general_study
  end
end
