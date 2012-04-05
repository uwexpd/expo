class AddFieldsForAcceptingAwardsToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :uses_award_acceptance, :boolean
    add_column :offerings, :enable_award_acceptance, :boolean
    add_column :offerings, :accepted_offering_status_id, :integer
    add_column :offerings, :declined_offering_status_id, :integer
    add_column :application_for_offerings, :declined, :boolean
    add_column :offerings, :acceptance_yes_text, :text
    add_column :offerings, :acceptance_no_text, :text
    add_column :offerings, :acceptance_instructions, :text
  end

  def self.down
    remove_column :offerings, :acceptance_instructions
    remove_column :offerings, :acceptance_no_text
    remove_column :offerings, :acceptance_yes_text
    remove_column :offerings, :enable_award_acceptance
    remove_column :offerings, :declined_offering_status_id
    remove_column :offerings, :accepted_offering_status_id
    remove_column :application_for_offerings, :declined
    remove_column :offerings, :uses_award_acceptance
  end
end
