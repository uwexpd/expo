class AddReviewerListCriteriaToOfferingAdminPhaseTask < ActiveRecord::Migration
  def self.up
    add_column :offering_admin_phase_tasks, :reviewer_list_criteria, :text
  end

  def self.down
    remove_column :offering_admin_phase_tasks, :reviewer_list_criteria
  end
end
