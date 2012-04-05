class AddFinishedEvaluationToOrganizationQuarter < ActiveRecord::Migration
  def self.up
    add_column :organization_quarters, :finished_evaluation, :boolean
  end

  def self.down
    remove_column :organization_quarters, :finished_evaluation
  end
end
