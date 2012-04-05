class ChangeApplicationInterviewers < ActiveRecord::Migration
  def self.up
    rename_column :application_interviewers, :person_id, :offering_interviewer_id
    add_column :application_interviewers, :comments, :text
  end

  def self.down
    rename_column :application_interviewers, :offering_interviewer_id, :person_id
    remove_column :application_interviewers, :comments
  end
end
