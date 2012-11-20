class AddIndexToApplicationAnswer < ActiveRecord::Migration
  def self.up
    add_index :application_answers, :application_for_offering_id
    add_index :application_answers, :offering_question_id
  end

  def self.down
    remove_index :application_answers, :application_for_offering_id
    remove_index :application_answers, :offering_question_id
  end
end
