class AddInterviewToCommittee < ActiveRecord::Migration
  def self.up
    add_column :committees, :interview_offering_id, :integer
  end

  def self.down
    remove_column :committees, :interview_offering_id
  end
end
