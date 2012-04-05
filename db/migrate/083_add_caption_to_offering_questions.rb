class AddCaptionToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :caption, :text
  end

  def self.down
    remove_column :offering_questions, :caption
  end
end
