class AddThemeResponse3ToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :theme_response3, :integer
  end

  def self.down
    remove_column :application_for_offerings, :theme_response3
  end
end
