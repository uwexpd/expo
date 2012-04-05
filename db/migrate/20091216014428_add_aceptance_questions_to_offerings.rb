class AddAceptanceQuestionsToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :acceptance_question1, :string
    add_column :offerings, :acceptance_question2, :string
    add_column :offerings, :acceptance_question3, :string
    add_column :application_for_offerings, :acceptance_response1, :text
    add_column :application_for_offerings, :acceptance_response2, :text
    add_column :application_for_offerings, :acceptance_response3, :text
    add_column :application_for_offerings, :award_accepted_at, :datetime
  end

  def self.down
    remove_column :application_for_offerings, :award_accepted_at
    remove_column :application_for_offerings, :acceptance_response3
    remove_column :application_for_offerings, :acceptance_response2
    remove_column :application_for_offerings, :acceptance_response1
    remove_column :offerings, :acceptance_question3
    remove_column :offerings, :acceptance_question2
    remove_column :offerings, :acceptance_question1
  end
end
