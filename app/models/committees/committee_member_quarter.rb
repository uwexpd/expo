class CommitteeMemberQuarter < ActiveRecord::Base
  stampable
  belongs_to :committee_member
  belongs_to :committee_quarter
  delegate :title, :quarter, :comments_prompt_text, :to => :committee_quarter
  
  def <=>(o)
    quarter <=> o.quarter
  end
  
end
