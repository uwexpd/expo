class AddTypeAndCategoryToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :application_type_id, :integer
    add_column :application_for_offerings, :application_category_id, :integer
    ApplicationForOffering::Deleted.update_columns
  end

  def self.down
    remove_column :application_for_offerings, :application_category_id
    remove_column :application_for_offerings, :application_type_id
    ApplicationForOffering::Deleted.update_columns
  end
end
