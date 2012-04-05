class AddAllowOtherCategoryToOfferingApplicationType < ActiveRecord::Migration
  def self.up
    add_column :offering_application_types, :allow_other_category, :boolean
    add_column :application_for_offerings, :other_category_title, :string
  end

  def self.down
    remove_column :application_for_offerings, :other_category_title
    remove_column :offering_application_types, :allow_other_category
  end
end
