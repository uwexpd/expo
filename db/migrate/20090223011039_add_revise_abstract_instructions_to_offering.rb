class AddReviseAbstractInstructionsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :revise_abstract_instructions, :text
  end

  def self.down
    remove_column :offerings, :revise_abstract_instructions
  end
end
