class AddInstructionsFieldsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :reviewer_instructions, :text
    add_column :offerings, :interviewer_instructions, :text
  end

  def self.down
    remove_column :offerings, :interviewer_instructions
    remove_column :offerings, :reviewer_instructions
  end
end
