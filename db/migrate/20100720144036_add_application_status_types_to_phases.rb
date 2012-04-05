class AddApplicationStatusTypesToPhases < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phases, :in_progress_application_status_types, :text
    add_column :offering_admin_phases, :success_application_status_types, :text
    add_column :offering_admin_phases, :failure_application_status_types, :text
    drop_table :offering_admin_phase_application_status_types
  end

  def self.down
    create_table "offering_admin_phase_application_status_types", :force => true do |t|
      t.integer  "offering_admin_phase_id"
      t.integer  "application_status_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "result_type"
    end
    
    remove_column :offering_admin_phases, :failure_application_status_types
    remove_column :offering_admin_phases, :success_application_status_types
    remove_column :offering_admin_phases, :in_progress_application_status_types
  end
end
