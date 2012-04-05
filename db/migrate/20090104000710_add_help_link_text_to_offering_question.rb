class AddHelpLinkTextToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :help_link_text, :string
  end

  def self.down
    remove_column :offering_questions, :help_link_text
  end
end
