class CreateOfferingAdminPhaseApplicationStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :offering_admin_phase_application_status_types do |t|
      t.integer :offering_admin_phase_id
      t.integer :application_status_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_admin_phase_application_status_types
  end
end
