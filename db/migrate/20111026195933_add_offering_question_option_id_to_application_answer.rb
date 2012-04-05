class AddOfferingQuestionOptionIdToApplicationAnswer < ActiveRecord::Migration
  def self.up
    add_column :application_answers, :offering_question_option_id, :integer
  end

  def self.down
    remove_column :application_answers, :offering_question_option_id
  end
end
