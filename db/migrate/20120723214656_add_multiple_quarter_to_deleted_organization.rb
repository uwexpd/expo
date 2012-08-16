class AddMultipleQuarterToDeletedOrganization < ActiveRecord::Migration
  def self.up
    add_column :deleted_organizations, :multiple_quarter, :boolean
  end

  def self.down
    remove_column :deleted_organizations, :multiple_quarter
  end
end
