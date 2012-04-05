class AddAllowToReviewMenteeToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :allow_to_review_mentee, :boolean, :default => false
  end

  def self.down
    remove_column :offerings, :allow_to_review_mentee
  end
end
