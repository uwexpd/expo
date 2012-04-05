class AddDisplayAsToOfferingQuestions < ActiveRecord::Migration
  def self.up
    remove_column :offering_questions, :offering_question_type_id
    add_column :offering_questions, :display_as, :string
  end

  def self.down
    add_column :offering_questions, :offering_question_type_id, :integer
    remove_column :offering_questions, :display_as
  end
end
