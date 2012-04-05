class CreateEvaluationResponses < ActiveRecord::Migration
  def self.up
    create_table :evaluation_responses do |t|
      t.integer :evaluation_id
      t.integer :evaluation_question_id
      t.text :response
      t.integer :creator_id
      t.integer :updater_id

      t.timestamps
    end
  end

  def self.down
    drop_table :evaluation_responses
  end
end
