class AddMinMaxFieldsToOfferings < ActiveRecord::Migration
  def self.up
    add_column :offerings, :max_number_of_mentors, :integer
    add_column :application_mentors, :waive_access_review_right, :boolean
    
  end

  def self.down
    remove_column :application_mentors, :waive_access_review_right
    remove_column :offerings, :max_number_of_mentors
  end
end
