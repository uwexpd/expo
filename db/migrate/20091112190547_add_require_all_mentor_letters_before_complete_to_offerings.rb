class AddRequireAllMentorLettersBeforeCompleteToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :require_all_mentor_letters_before_complete, :boolean
  end

  def self.down
    remove_column :offerings, :require_all_mentor_letters_before_complete
  end
end
