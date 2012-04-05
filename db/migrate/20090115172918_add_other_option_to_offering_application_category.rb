class AddOtherOptionToOfferingApplicationCategory < ActiveRecord::Migration
  def self.up
    add_column :offering_application_categories, :other_option, :boolean
  end

  def self.down
    remove_column :offering_application_categories, :other_option
  end
end
