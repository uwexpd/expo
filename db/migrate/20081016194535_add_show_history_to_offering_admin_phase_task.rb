class AddShowHistoryToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :show_history, :boolean
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :show_history
  end
end
