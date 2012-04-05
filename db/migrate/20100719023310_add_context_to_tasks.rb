class AddContextToTasks < ActiveRecord::Migration
  def self.up
    rename_column :offering_admin_phase_tasks, :task_type, :context
    add_column :application_for_offerings, :task_completion_status_cache, :text
    add_column :application_mentors, :task_completion_status_cache, :text
    add_column :application_reviewers, :task_completion_status_cache, :text
    add_column :application_interviewers, :task_completion_status_cache, :text
    add_column :application_group_members, :task_completion_status_cache, :text
    add_column :offering_admin_phase_tasks, :completion_criteria, :text
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :completion_criteria
    remove_column :application_group_members, :task_completion_status_cache
    remove_column :application_interviewers, :task_completion_status_cache
    remove_column :application_reviewers, :task_completion_status_cache
    remove_column :application_mentors, :task_completion_status_cache
    remove_column :application_for_offerings, :task_completion_status_cache
    rename_column :offering_admin_phase_tasks, :context, :task_type
  end
end
