class CreateApplicationMentorAnswers < ActiveRecord::Migration
  def self.up
    create_table :application_mentor_answers do |t|
      t.integer :application_mentor_id
      t.integer :offering_mentor_question_id
      t.text :answer

      t.timestamps
    end
  end

  def self.down
    drop_table :application_mentor_answers
  end
end
