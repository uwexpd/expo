class AddExtraQuarterIdToApplicationAwards < ActiveRecord::Migration
  def self.up
    add_column :application_awards, :disbersement_quarter_id, :integer
    rename_column :application_awards, :quarter_id, :requested_quarter_id
  end

  def self.down
    remove_column :application_awards, :disbersement_quarter_id
    rename_column :application_awards, :requested_quarter_id, :quarter_id
  end
end
