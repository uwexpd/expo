class AddRequiredToOfferingMentorType < ActiveRecord::Migration
  def self.up
    add_column :offering_mentor_types, :meets_minimum_qualification, :boolean
  end

  def self.down
    remove_column :offering_mentor_types, :meets_minimum_qualification
  end
end
