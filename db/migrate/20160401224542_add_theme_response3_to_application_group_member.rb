class AddThemeResponse3ToApplicationGroupMember < ActiveRecord::Migration
  def self.up
    add_column :application_group_members, :theme_response3, :integer
  end

  def self.down
    remove_column :application_group_members, :theme_response3
  end
end
