class AddSymposiumCustomizationsToCommitteeStuff < ActiveRecord::Migration
  def self.up
    add_column :committees, :inactive_text, :text
    add_column :committees, :complete_text, :text
    add_column :committee_quarters, :comments_prompt_text, :string
    add_column :committees, :active_action_text, :string
  end

  def self.down
    remove_column :committees, :active_action_text
    remove_column :committee_quarters, :comments_prompt_text
    remove_column :committees, :complete_text
    remove_column :committees, :inactive_text
  end
end
