class CreateOfferingMentorQuestions < ActiveRecord::Migration
  def self.up
    create_table :offering_mentor_questions do |t|
      t.integer :offering_id
      t.text :question
      t.boolean :required
      t.boolean :must_be_number
      t.string :display_as
      t.integer :size

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_mentor_questions
  end
end
