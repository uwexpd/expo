class AddOtherScholarshipSupportToApplicationForOfferings < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :other_scholarship_support, :text
  end

  def self.down
    remove_column :application_for_offerings, :other_scholarship_support
  end
end
