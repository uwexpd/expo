# A Committee is a group of people, typically associated with an activity. Using committees allows us to track these groups across quarters, for example, of online applications like the Mary Gates Endowment research scholarhips. A Committee has multiple CommitteeMembers who can be on the committee and be marked active or inactive for many Quarters.
# 
# Offerings use Committees to track the potential list of reviewers and interviewers for each award process.
class Committee < ActiveRecord::Base
  stampable
  has_many :members, :class_name => "CommitteeMember" do
    def active
      find_all{|m| m.currently_active? && m.responded_recently? }
    end
    def inactive
      reject{|m| m.currently_active? }
    end
    def permanently_inactive
      find(:all, :conditions => { :permanently_inactive => true })
    end
    def not_responded
      reject{|m| m.responded_recently? }
    end
    def of_type(member_type)
      find(:all, :conditions => {:committee_member_type_id => member_type.id})
    end
    def active_for(quarter)
      find_all{|m| m.active_for?(quarter) }
    end
  end
    
  has_many :committee_quarters do
    def upcoming(limit = 4, reference_quarter = Quarter.current_quarter)
      reject{|q| q.quarter < reference_quarter}.sort[0..(limit-1)]
    end
  end
  
  has_many :quarters, :through => :committee_quarters, :source => :quarter do
    def upcoming(limit = 4, reference_quarter = Quarter.current_quarter)
      reject{|q| q < reference_quarter}.sort[0..(limit-1)]
    end
  end
  
  has_many :member_types, :class_name => "CommitteeMemberType"

  has_many :meetings, :class_name => "CommitteeMeeting" do
    def future
      reject{|m| m.past? }
    end
    def past
      reject{|m| !m.past? }
    end
  end
    
  PLACEHOLDER_CODES = %w(name)

  after_save :update_member_status_caches!
  
  # Admin users can customize the prompt that is shown next to the checkbox that a committee member clicks to say whether or not they
  # will participate for a given quarter. If the admins leave this value blank, then we return a default value of "I can participate for".
  def active_action_text
    read_attribute(:active_action_text).blank? ? "I can participate for" : read_attribute(:active_action_text)
  end

  # When changing the response_reset_date, we must go through and update the status_cache for all members of the committee.
  def update_member_status_caches!
    if response_reset_date_changed?
      members.find_in_batches do |member_group|
        member_group.each {|member| member.update_status_cache! }
      end
    end
  end

  # If this Committee has the response_reset_date set, return that. Otherwise, calculate this based on the DEFAULT_LIFETIME_RESPONSE.
  def response_lifetime_date
    response_reset_date || CommitteeMember::DEFAULT_RESPONSE_LIFETIME.ago
  end
  
end
