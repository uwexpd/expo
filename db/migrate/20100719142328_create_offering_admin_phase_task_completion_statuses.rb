class CreateOfferingAdminPhaseTaskCompletionStatuses < ActiveRecord::Migration
  def self.up
    create_table :offering_admin_phase_task_completion_statuses do |t|
      t.integer :task_id
      t.string :taskable_type
      t.integer :taskable_id
      t.integer :creator_id
      t.integer :updater_id
      t.text :result
      t.boolean :complete
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :offering_admin_phase_task_completion_statuses
  end
end
