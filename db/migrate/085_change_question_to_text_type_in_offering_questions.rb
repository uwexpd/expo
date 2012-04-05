class ChangeQuestionToTextTypeInOfferingQuestions < ActiveRecord::Migration
  def self.up
    change_column :offering_questions, :question, :text
  end

  def self.down
    change_column :offering_questions, :question, :string
  end
end
