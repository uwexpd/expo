class CreateEvaluationQuestions < ActiveRecord::Migration
  def self.up
    create_table :evaluation_questions do |t|
      t.integer :evaluation_questionable_id
      t.string :evaluation_questionable_type
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_questions
  end
end
