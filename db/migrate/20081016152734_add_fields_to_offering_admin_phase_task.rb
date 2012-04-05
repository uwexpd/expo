class AddFieldsToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :application_status_types, :string
    add_column :offering_admin_phase_tasks, :new_application_status_type, :string
    add_column :offering_admin_phase_tasks, :email_templates, :string
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :email_templates
    remove_column :offering_admin_phase_tasks, :new_application_status_type
    remove_column :offering_admin_phase_tasks, :application_status_types
  end
end
