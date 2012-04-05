class AddUseMceToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :use_mce_editor, :boolean
  end

  def self.down
    remove_column :offering_questions, :use_mce_editor
  end
end
