class AddConfirmationFieldsForApplications < ActiveRecord::Migration
  def self.up
    add_column :offerings, :confirmation_instructions, :text
    add_column :offerings, :confirmation_yes_text, :text
    add_column :offerings, :guest_invitation_instructions, :text
    add_column :offerings, :guest_postcard_layout, :text
    add_column :offerings, :theme_response_instructions, :text
    add_column :offerings, :nomination_instructions, :text
    add_column :application_for_offerings, :confirmed, :boolean
    add_column :application_for_offerings, :theme_response, :text
    add_column :application_for_offerings, :nominated_mentor_id, :integer
    add_column :application_for_offerings, :nominated_mentor_explanation, :text
    add_column :application_group_members, :nominated_mentor_id, :integer
    add_column :application_group_members, :nominated_mentor_explanation, :text
    add_column :application_group_members, :confirmed, :boolean
    add_column :application_group_members, :theme_response, :text
  end

  def self.down
    remove_column :offerings, :nomination_instructions
    remove_column :offerings, :theme_response_instructions
    remove_column :offerings, :guest_postcard_layout
    remove_column :offerings, :confirmation_yes_text
    remove_column :offerings, :confirmation_instructions
    remove_column :offerings, :guest_invitation_instructions
    remove_column :application_for_offerings, :nominated_mentor_explanation
    remove_column :application_for_offerings, :nominated_mentor_id
    remove_column :application_for_offerings, :theme_response
    remove_column :application_for_offerings, :confirmed
    remove_column :application_group_members, :theme_response
    remove_column :application_group_members, :confirmed
    remove_column :application_group_members, :nominated_mentor_explanation
    remove_column :application_group_members, :nominated_mentor_id
  end
end
