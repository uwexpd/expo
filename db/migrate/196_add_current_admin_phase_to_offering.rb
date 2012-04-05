class AddCurrentAdminPhaseToOffering < ActiveRecord::Migration
  def self.up
    add_column :offerings, :current_offering_admin_phase_id, :integer
  end

  def self.down
    remove_column :offerings, :current_offering_admin_phase_id
  end
end
