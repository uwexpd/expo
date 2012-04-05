class AddSequenceToOrganizationQuarterStatusTypes < ActiveRecord::Migration
  def self.up
    add_column :organization_quarter_status_types, :sequence, :integer
  end

  def self.down
    remove_column :organization_quarter_status_types, :sequence
  end
end
