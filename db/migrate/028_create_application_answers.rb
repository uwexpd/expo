class CreateApplicationAnswers < ActiveRecord::Migration
  def self.up
    create_table :application_answers do |t|
      t.integer :application_for_offering_id
      t.integer :offering_question_id
      t.text :answer

      t.timestamps
    end
  end

  def self.down
    drop_table :application_answers
  end
end
