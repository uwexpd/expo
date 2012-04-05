class AddSymposiumFieldsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :type, :string
    add_column :offerings, :year_offered, :integer
    add_column :offerings, :ask_applicant_to_waive_mentor_access_right, :boolean
    add_column :offerings, :allow_hard_copy_letters_from_mentors, :boolean
  end

  def self.down
    remove_column :offerings, :allow_hard_copy_letters_from_mentors
    remove_column :offerings, :ask_applicant_to_waive_mentor_access_right
    remove_column :offerings, :year_offered
    remove_column :offerings, :type
  end
end
