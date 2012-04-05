class AddDynamicAnswerToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :dynamic_answer, :boolean
  end

  def self.down
    remove_column :offering_questions, :dynamic_answer
  end
end
