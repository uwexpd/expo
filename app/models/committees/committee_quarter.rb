class CommitteeQuarter < ActiveRecord::Base
  stampable
  belongs_to :committee
  belongs_to :quarter
  
  has_many :committee_member_quarters, :dependent => :destroy do
    def active; find(:all, :conditions => {:active => true}); end
  end
  
  validates_presence_of :quarter_id
  validates_uniqueness_of :quarter_id, :scope => :committee_id
  
  def <=>(o)
    quarter <=> o.quarter
  end

  # Admin users can customize the prompt that is shown next to the comments field for this quarter. This method provides a default value
  # of simple "Comments?"
  def comments_prompt_text
    read_attribute(:comments_prompt_text).blank? ? "Comments?" : read_attribute(:comments_prompt_text)
  end

  # If there is an alternate title defined, return that. Otherwise, return the title of +quarter+.
  def title
    alternate_title.blank? ? quarter.title : alternate_title
  end

end
