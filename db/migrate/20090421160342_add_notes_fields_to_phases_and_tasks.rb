class AddNotesFieldsToPhasesAndTasks < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phases, :notes, :text
    add_column :offering_admin_phase_tasks, :notes, :text
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :notes
    remove_column :offering_admin_phases, :notes
  end
end
