class AddDestroyByDateToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :destroy_by, :string
  end

  def self.down
    remove_column :offerings, :destroy_by
  end
end
