class AddIndicesToOfferingAdminPhaseTaskCompletionStatuses < ActiveRecord::Migration
  def self.up
    add_index :offering_admin_phase_task_completion_statuses, [:task_id], :name => "task_id_index"
    add_index :offering_admin_phase_task_completion_statuses, [:taskable_type, :taskable_id], :name => "taskable_index"
  end

  def self.down
    remove_index :offering_admin_phase_task_completion_statuses, :name => :taskable_index
    remove_index :offering_admin_phase_task_completion_statuses, :task_id
  end
end
