class AddThemeResponse3ToDeletedApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :deleted_application_for_offerings, :theme_response3, :integer
  end

  def self.down
    remove_column :deleted_application_for_offerings, :theme_response3
  end
end
