class AddDisplayAsToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :display_as, :string
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :display_as
  end
end
