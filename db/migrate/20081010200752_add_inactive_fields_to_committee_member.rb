class AddInactiveFieldsToCommitteeMember < ActiveRecord::Migration
  def self.up
    add_column :committee_members, :inactive, :boolean
    add_column :committee_members, :permanently_inactive, :boolean
    add_column :committee_members, :comment, :text
    add_column :committee_members, :notes, :text
  end

  def self.down
    remove_column :committee_members, :notes
    remove_column :committee_members, :comment
    remove_column :committee_members, :permanently_inactive
    remove_column :committee_members, :inactive
  end
end
