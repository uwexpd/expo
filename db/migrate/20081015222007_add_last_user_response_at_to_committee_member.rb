class AddLastUserResponseAtToCommitteeMember < ActiveRecord::Migration
  def self.up
    add_column :committee_members, :last_user_response_at, :datetime
  end

  def self.down
    remove_column :committee_members, :last_user_response_at
  end
end
