class AddSequenceToOfferingApplicationCategory < ActiveRecord::Migration
  def self.up
    add_column :offering_application_categories, :sequence, :integer
  end

  def self.down
    remove_column :offering_application_categories, :sequence
  end
end
