class AddStatusCacheToCommitteeMembers < ActiveRecord::Migration
  def self.up
    add_column :committee_members, :status_cache, :string
    
    CommitteeMember.find_in_batches do |member_group|
      member_group.each { |member| member.update_status_cache! }
    end
  end

  def self.down
    remove_column :committee_members, :status_cache
  end
end
