class AddSequenceToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :sequence, :integer
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :sequence
  end
end
