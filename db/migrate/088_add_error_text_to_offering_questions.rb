class AddErrorTextToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :error_text, :text
  end

  def self.down
    remove_column :offering_questions, :error_text
  end
end
