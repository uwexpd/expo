class AddTargetSchoolBoolToOrgs < ActiveRecord::Migration
  def self.up
    add_column :organizations, :target_school, :boolean
  end

  def self.down
    remove_column :organizations, :target_school
  end
end
