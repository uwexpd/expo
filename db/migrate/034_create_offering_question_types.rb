class CreateOfferingQuestionTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_question_types do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_question_types
  end
end
