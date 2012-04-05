class AddTaskCompletionCachesToReviewersAndCommitteeMembers < ActiveRecord::Migration
  def self.up
    add_column :offering_interviewers, :task_completion_status_cache, :text
    add_column :committee_members, :task_completion_status_cache, :text
  end

  def self.down
    remove_column :committee_members, :task_completion_status_cache
    remove_column :offering_interviewers, :task_completion_status_cache
  end
end
