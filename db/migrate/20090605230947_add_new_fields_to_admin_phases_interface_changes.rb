class AddNewFieldsToAdminPhasesInterfaceChanges < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phases, :show_progress_completion, :boolean, :default => true
    add_column :offering_admin_phase_tasks, :progress_column_title, :string
    add_column :offering_admin_phase_tasks, :progress_display_criteria, :text
    add_column :offering_admin_phase_tasks, :task_type, :string  # :applicant or :reviewer or other
    add_column :offering_admin_phase_application_status_types, :result_type, :string  # :success or :failure
    add_column :offering_admin_phase_tasks, :show_for_success, :boolean
    add_column :offering_admin_phase_tasks, :show_for_failure, :boolean
    add_column :offering_admin_phase_tasks, :show_for_in_progress, :boolean
    add_column :offering_admin_phases, :show_each_status_separately, :boolean
  end

  def self.down
    remove_column :offering_admin_phases, :show_each_status_separately
    remove_column :offering_admin_phase_tasks, :show_for_in_progress
    remove_column :offering_admin_phase_tasks, :show_for_failure
    remove_column :offering_admin_phase_tasks, :show_for_success
    remove_column :offering_admin_phase_application_status_types, :result_type
    remove_column :offering_admin_phase_tasks, :task_type
    remove_column :offering_admin_phase_tasks, :progress_display_criteria
    remove_column :offering_admin_phase_tasks, :progress_column_title
    remove_column :offering_admin_phases, :show_progress_completion
  end
end
