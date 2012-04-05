class AddLogoToUnit < ActiveRecord::Migration
  def self.up
    add_column :units, :logo, :string
  end

  def self.down
    remove_column :units, :logo
  end
end
