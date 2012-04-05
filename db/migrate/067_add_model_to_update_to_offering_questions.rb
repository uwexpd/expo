class AddModelToUpdateToOfferingQuestions < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :model_to_update, :string
  end

  def self.down
    remove_column :offering_questions, :model_to_update
  end
end
