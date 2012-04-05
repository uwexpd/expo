class AddEaselFieldsToOfferingSections < ActiveRecord::Migration
  def self.up
    add_column :offering_location_sections, :starting_easel_number, :integer
    add_column :offering_location_sections, :ending_easel_number, :integer
    add_column :application_for_offerings, :lock_easel_number, :boolean
  end

  def self.down
    remove_column :application_for_offerings, :lock_easel_number
    remove_column :offering_location_sections, :ending_easel_number
    remove_column :offering_location_sections, :starting_easel_number
  end
end
