class AddMentorInstructionsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :mentor_instructions, :text
  end

  def self.down
    remove_column :offerings, :mentor_instructions
  end
end
