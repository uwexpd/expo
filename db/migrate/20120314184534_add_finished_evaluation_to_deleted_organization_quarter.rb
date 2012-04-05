class AddFinishedEvaluationToDeletedOrganizationQuarter < ActiveRecord::Migration
  def self.up
    add_column :deleted_organization_quarters, :finished_evaluation, :boolean
  end

  def self.down
    remove_column :deleted_organization_quarters, :finished_evaluation
  end
end
