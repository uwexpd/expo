class AddQuestionAndDisplayAsAndSequenceToEvaluationQuestion < ActiveRecord::Migration
  def self.up
    add_column :evaluation_questions, :question, :text
    add_column :evaluation_questions, :display_as, :string
    add_column :evaluation_questions, :sequence, :integer
    add_column :evaluation_questions, :required, :boolean
  end

  def self.down
    remove_column :evaluation_questions, :required
    remove_column :evaluation_questions, :sequence
    remove_column :evaluation_questions, :display_as
    remove_column :evaluation_questions, :question
  end
end
