class CreateOfferingQuestionOptions < ActiveRecord::Migration
  def self.up
    create_table :offering_question_options do |t|
      t.integer :offering_question_id
      t.string :name
      t.string :detail

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_question_options
  end
end
