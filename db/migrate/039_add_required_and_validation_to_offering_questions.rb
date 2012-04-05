class AddRequiredAndValidationToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :required, :boolean
    add_column :offering_questions, :validation_criteria, :string
  end

  def self.down
    remove_column :offering_questions, :validation_criteria
    remove_column :offering_questions, :required
  end
end
