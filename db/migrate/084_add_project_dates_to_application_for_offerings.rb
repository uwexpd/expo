class AddProjectDatesToApplicationForOfferings < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :project_dates, :string
  end

  def self.down
    remove_column :application_for_offerings, :project_dates
  end
end
