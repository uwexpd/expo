class CreateOfferingQuestions < ActiveRecord::Migration
  def self.up
    create_table :offering_questions do |t|
      t.integer :offering_page_id
      t.integer :offering_question_type_id
      t.string :question
      t.integer :ordering

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_questions
  end
end
