class AddSpecialNotesToOfferingInterviewer < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :special_notes, :text
  end

  def self.down
    remove_column :offering_interviewers, :special_notes
  end
end
