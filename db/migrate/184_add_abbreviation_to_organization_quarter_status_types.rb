class AddAbbreviationToOrganizationQuarterStatusTypes < ActiveRecord::Migration
  def self.up
    add_column :organization_quarter_status_types, :abbreviation, :string
  end

  def self.down
    remove_column :organization_quarter_status_types, :abbreviation
  end
end
