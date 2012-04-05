class ChangeOfferingQuestionOptions < ActiveRecord::Migration
  def self.up
    rename_column :offering_question_options, :name, :value
    rename_column :offering_question_options, :detail, :title
  end

  def self.down
    rename_column :offering_question_options, :value, :name
    rename_column :offering_question_options, :title, :detail
  end
end
