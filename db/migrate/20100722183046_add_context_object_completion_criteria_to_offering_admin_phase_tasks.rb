class AddContextObjectCompletionCriteriaToOfferingAdminPhaseTasks < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :context_object_completion_criteria, :text
    add_column :offering_admin_phase_tasks, :context_object_progress_display_criteria, :text
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :context_object_progress_display_criteria
    remove_column :offering_admin_phase_tasks, :context_object_completion_criteria
  end
end
