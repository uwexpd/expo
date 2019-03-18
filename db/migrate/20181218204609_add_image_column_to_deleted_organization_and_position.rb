class AddImageColumnToDeletedOrganizationAndPosition < ActiveRecord::Migration
  def self.up
    add_column :deleted_organizations, :logo, :string
    add_column :deleted_service_learning_positions, :picture, :string
  end

  def self.down
    remove_column :deleted_organizations, :logo
    remove_column :deleted_service_learning_positions, :picture
  end
end
