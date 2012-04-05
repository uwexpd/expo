class AddCustomErrorTextToOfferingQuestionValidations < ActiveRecord::Migration
  def self.up
    add_column :offering_question_validations, :custom_error_text, :text
  end

  def self.down
    remove_column :offering_question_validations, :custom_error_text
  end
end
