class LocationNeighborhoodAddition < ActiveRecord::Migration
  def self.up
    add_column :locations, :neighborhood, :string
  end

  def self.down
    remove_column :locations, :neighborhood
  end
end
