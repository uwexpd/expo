class AddAttributeToUpdateToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :attribute_to_update, :string
  end

  def self.down
    remove_column :offering_questions, :attribute_to_update
  end
end
