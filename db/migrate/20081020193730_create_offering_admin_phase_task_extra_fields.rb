class CreateOfferingAdminPhaseTaskExtraFields < ActiveRecord::Migration
  def self.up
    create_table :offering_admin_phase_task_extra_fields do |t|
      t.integer :offering_admin_phase_task_id
      t.string :title
      t.text :display_method

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_admin_phase_task_extra_fields
  end
end
