class AddFieldsToOfferingInterviewer < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :first_time, :boolean
    add_column :offering_interviewers, :off_campus, :boolean
    add_column :offering_interviewers, :past_scholar, :boolean
  end

  def self.down
    remove_column :offering_interviewers, :past_scholar
    remove_column :offering_interviewers, :off_campus
    remove_column :offering_interviewers, :first_time
  end
end
