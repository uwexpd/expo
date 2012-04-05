class AddDepartmentToCommitteeMember < ActiveRecord::Migration
  def self.up
    add_column :committee_members, :department, :string
  end

  def self.down
    remove_column :committee_members, :department
  end
end
