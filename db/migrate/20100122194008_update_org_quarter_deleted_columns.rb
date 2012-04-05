class UpdateOrgQuarterDeletedColumns < ActiveRecord::Migration
  def self.up
    OrganizationQuarter::Deleted.update_columns
  end

  def self.down
    OrganizationQuarter::Deleted.update_columns
  end
end
