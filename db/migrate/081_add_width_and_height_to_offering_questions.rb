class AddWidthAndHeightToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :width, :integer
    add_column :offering_questions, :height, :integer
  end

  def self.down
    remove_column :offering_questions, :height
    remove_column :offering_questions, :width
  end
end
