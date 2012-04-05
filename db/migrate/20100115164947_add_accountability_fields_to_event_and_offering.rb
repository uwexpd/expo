class AddAccountabilityFieldsToEventAndOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :count_method_for_accountability, :string
    add_column :events, :activity_type_id, :integer
    add_column :events, :pull_accountability_hours_from_application, :integer
  end

  def self.down
    remove_column :events, :pull_accountability_hours_from_application
    remove_column :events, :activity_type_id
    remove_column :offerings, :count_method_for_accountability
  end
end
