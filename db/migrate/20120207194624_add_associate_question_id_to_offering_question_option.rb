class AddAssociateQuestionIdToOfferingQuestionOption < ActiveRecord::Migration
  def self.up
    add_column :offering_question_options, :associate_question_id, :integer
  end

  def self.down
    remove_column :offering_question_options, :associate_question_id
  end
end
