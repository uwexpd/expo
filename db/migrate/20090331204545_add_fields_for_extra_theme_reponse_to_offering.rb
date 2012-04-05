class AddFieldsForExtraThemeReponseToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :theme_response_title, :string
    add_column :offerings, :theme_response2_instructions, :string
    add_column :offerings, :theme_response_type, :string
    add_column :offerings, :theme_response2_type, :string
    add_column :application_for_offerings, :theme_response2, :text
    add_column :application_group_members, :theme_response2, :text
  end

  def self.down
    remove_column :application_group_members, :theme_response2
    remove_column :application_for_offerings, :theme_response2
    remove_column :offerings, :theme_response2_type
    remove_column :offerings, :theme_response_type
    remove_column :offerings, :theme_response2_instructions
    remove_column :offerings, :theme_response_title
  end
end
