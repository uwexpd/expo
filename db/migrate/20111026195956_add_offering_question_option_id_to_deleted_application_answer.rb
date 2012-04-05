class AddOfferingQuestionOptionIdToDeletedApplicationAnswer < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_answers, :offering_question_option_id, :integer
  end

  def self.down
    remove_column :deleted_application_answers, :offering_question_option_id
  end
end
