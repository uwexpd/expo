class AddShortTitleToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :short_title, :string
  end

  def self.down
    remove_column :offering_questions, :short_title
  end
end
