class AddMultipleQuarterToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :multiple_quarter, :boolean
  end

  def self.down
    remove_column :organizations, :multiple_quarter
  end
end
