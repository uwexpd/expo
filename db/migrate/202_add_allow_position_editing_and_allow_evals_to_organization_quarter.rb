class AddAllowPositionEditingAndAllowEvalsToOrganizationQuarter < ActiveRecord::Migration
  def self.up
    add_column :organization_quarters, :allow_position_edits, :boolean
    add_column :organization_quarters, :allow_evals, :boolean
  end

  def self.down
    remove_column :organization_quarters, :allow_evals
    remove_column :organization_quarters, :allow_position_edits
  end
end
