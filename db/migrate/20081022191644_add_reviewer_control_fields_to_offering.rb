class AddReviewerControlFieldsToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :min_number_of_reviews_per_applicant, :integer
    add_column :committee_member_types, :max_number_of_applicants_per_reviewer, :integer
  end

  def self.down
    remove_column :committee_member_types, :max_number_of_applicants_per_reviewer
    remove_column :offerings, :min_number_of_reviews_per_applicant
  end
end
