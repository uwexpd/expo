class AddSessionAndModeratorFieldsToOfferingAndApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :moderator_committee_id, :integer
    add_column :offerings, :moderator_instructions, :text
    add_column :offerings, :moderator_criteria, :text
    add_column :application_for_offerings, :offering_session_id, :integer
    add_column :application_for_offerings, :application_moderator_decision_type_id, :integer
    add_column :application_for_offerings, :moderator_comments, :text
    add_column :application_for_offerings, :offering_session_order, :integer
  end

  def self.down
    remove_column :application_for_offerings, :offering_session_order
    remove_column :application_for_offerings, :moderator_comments
    remove_column :application_for_offerings, :application_moderator_decision_type_id
    remove_column :application_for_offerings, :offering_session_id
    remove_column :offerings, :moderator_criteria
    remove_column :offerings, :moderator_instructions
    remove_column :offerings, :moderator_committee_id
  end
end
