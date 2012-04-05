class AddNotesToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :notes, :text
  end

  def self.down
    remove_column :offerings, :notes
  end
end
