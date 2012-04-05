class AddProjectSummaryToApplicationForOffering < ActiveRecord::Migration
  def self.up
    add_column :application_for_offerings, :project_summary, :text
  end

  def self.down
    remove_column :application_for_offerings, :project_summary
  end
end
