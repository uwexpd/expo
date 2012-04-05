class CommitteeMeeting < ActiveRecord::Base
  stampable
  belongs_to :committee
  has_many :committee_member_meetings, :dependent => :destroy do
    def attending; find(:all, :conditions => { :attending => true }); end
    def not_attending; find(:all, :conditions => { :attending => false }); end
  end

  validates_presence_of :title
  validates_presence_of :start_date
  
  def <=>(o)
    start_date <=> o.start_date
  end
  
  # Returns true if this meeting already occurred
  def past?
    start_date < Time.now
  end

end
