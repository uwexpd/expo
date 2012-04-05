class RenameAllowAppTypesInOfferingApplicationCategory < ActiveRecord::Migration
  def self.up
    remove_column :offering_application_categories, :app_types_allowed
    add_column :offering_application_categories, :offering_application_type_id, :integer
  end

  def self.down
    remove_column :offering_application_categories, :offering_application_type_id
    add_column :offering_application_categories, :app_types_allowed, :string
  end
end
