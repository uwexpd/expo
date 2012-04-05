class AddCommentsToOfferingInterviewInterviewers < ActiveRecord::Migration
  def self.up
    add_column :offering_interview_interviewers, :comments, :text
  end

  def self.down
    remove_column :offering_interview_interviewers, :comments
  end
end
