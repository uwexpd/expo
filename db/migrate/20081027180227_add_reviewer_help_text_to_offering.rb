class AddReviewerHelpTextToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :reviewer_help_text, :text
  end

  def self.down
    remove_column :offerings, :reviewer_help_text
  end
end
