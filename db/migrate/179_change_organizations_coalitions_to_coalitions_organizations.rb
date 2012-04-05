class ChangeOrganizationsCoalitionsToCoalitionsOrganizations < ActiveRecord::Migration
  def self.up
    rename_table :organizations_coalitions, :coalitions_organizations
  end

  def self.down
    rename_table :coalitions_organizations, :organizations_coalitions
    
  end
end
