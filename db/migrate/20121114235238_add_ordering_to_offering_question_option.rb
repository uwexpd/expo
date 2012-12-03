class AddOrderingToOfferingQuestionOption < ActiveRecord::Migration
  def self.up
    add_column :offering_question_options, :ordering, :string
  end

  def self.down
    remove_column :offering_question_options, :ordering
  end
end
