class AddLetterTemplatesToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :applicant_award_letter_template_id, :integer
    add_column :offerings, :mentor_award_letter_template_id, :integer
  end

  def self.down
    remove_column :offerings, :mentor_award_letter_template_id
    remove_column :offerings, :applicant_award_letter_template_id
  end
end
