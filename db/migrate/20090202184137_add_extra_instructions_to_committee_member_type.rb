class AddExtraInstructionsToCommitteeMemberType < ActiveRecord::Migration
  def self.up
    add_column :committee_member_types, :extra_instructions, :text
    add_column :committee_member_types, :extra_instructions_link_text, :string
  end

  def self.down
    remove_column :committee_member_types, :extra_instructions_link_text
    remove_column :committee_member_types, :extra_instructions
  end
end
