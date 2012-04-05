class AddProceedingsRequestToApplications < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :requests_printed_program, :boolean
    add_column :application_group_members, :requests_printed_program, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :requests_printed_program
    remove_column :application_group_members, :requests_printed_program
  end
end
