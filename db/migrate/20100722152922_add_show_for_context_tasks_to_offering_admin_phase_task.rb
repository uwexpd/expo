class AddShowForContextTasksToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :show_for_context_object_tasks, :boolean
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :show_for_context_object_tasks
  end
end
