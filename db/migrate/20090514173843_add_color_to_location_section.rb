class AddColorToLocationSection < ActiveRecord::Migration
  def self.up
    add_column :offering_location_sections, :color, :string
  end

  def self.down
    remove_column :offering_location_sections, :color
  end
end
