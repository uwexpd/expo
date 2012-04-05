class AddDetailTextAndUrlToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :detail_text, :text
    add_column :offering_admin_phase_tasks, :url, :string
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :url
    remove_column :offering_admin_phase_tasks, :detail_text
  end
end
