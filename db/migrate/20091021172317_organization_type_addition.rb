class OrganizationTypeAddition < ActiveRecord::Migration
  def self.up
    add_column :organizations, :type, :string
  end

  def self.down
    remove_column :organizations, :type
  end
end
