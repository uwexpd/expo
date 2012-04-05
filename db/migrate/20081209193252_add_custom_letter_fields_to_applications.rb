class AddCustomLetterFieldsToApplications < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :award_letter_text, :text
    add_column :application_mentors, :mentor_letter_text, :text
    add_column :people, :address_block, :text
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
  end

  def self.down
    remove_column :people, :address_block
    remove_column :application_mentors, :mentor_letter_text
    remove_column :application_for_offerings, :award_letter_text
    ApplicationForOffering::Deleted.update_columns
    ApplicationMentor::Deleted.update_columns
  end
end
