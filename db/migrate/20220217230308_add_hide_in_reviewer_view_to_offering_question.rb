class AddHideInReviewerViewToOfferingQuestion < ActiveRecord::Migration
  def self.up
    add_column :offering_questions, :hide_in_reviewer_view, :boolean
  end

  def self.down
    remove_column :offering_questions, :hide_in_reviewer_view
  end
end
