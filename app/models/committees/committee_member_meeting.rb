class CommitteeMemberMeeting < ActiveRecord::Base
  stampable
  belongs_to :committee_member
  belongs_to :committee_meeting
  
  def meeting
    committee_meeting
  end

  def <=>(o)
    committee_member.start_time <=> o.committee_member.start_time rescue -1
  end

end
