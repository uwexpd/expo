class AddUsesFieldsAndReviewerPastApplicationAccessToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :uses_moderators, :boolean
    add_column :offerings, :uses_mentors, :boolean, :default => true
    add_column :offerings, :reviewer_past_application_access, :string
    add_column :offerings, :uses_group_members, :boolean
    add_column :offerings, :uses_awards, :boolean, :default => true
    add_column :offerings, :uses_confirmation, :boolean
  end

  def self.down
    remove_column :offerings, :uses_confirmation
    remove_column :offerings, :uses_awards
    remove_column :offerings, :uses_group_members
    remove_column :offerings, :reviewer_past_application_access
    remove_column :offerings, :uses_mentors
    remove_column :offerings, :uses_moderators
  end
end
