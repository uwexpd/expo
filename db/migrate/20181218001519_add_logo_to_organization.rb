class AddLogoToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :logo, :string
  end

  def self.down
    remove_column :organizations, :logo
  end
end
