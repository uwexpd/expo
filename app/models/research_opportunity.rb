class ResearchOpportunity < ActiveRecord::Base
  
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :title
  validates_presence_of :department
  validates_presence_of :description
  validates_presence_of :requirements
  validates_presence_of :research_area1 
  validate :end_date_cannot_be_in_the_past
        
  def get_area_name(area_id)
    ResearchArea.find(area_id).name rescue nil
  end

  def self.find_by_research_area(lookup_area)
    all( :conditions => [ "active = ? and (research_area1 = ? OR research_area2 = ? OR research_area3 = ? OR research_area4 = ?)", true, lookup_area, lookup_area, lookup_area, lookup_area] )    
  end

  def self.find_by_keyword(keyword)
    keyword = keyword.downcase.strip.gsub(/\\/, '\&\&').gsub(/'/, "''").chomp(",").chomp(".").chomp("%")
    find :all,                                
         :conditions => "active = true AND (title LIKE '%#{keyword}%' OR department LIKE '%#{keyword}%' OR description LIKE '%#{keyword}%')",
         :order => "created_at DESC, title ASC"
  end

  def self.find_by_contact(contact_info)
    contact_info = contact_info.downcase.strip.gsub(/\\/, '\&\&').gsub(/'/, "''").chomp(",").chomp(".").chomp("%")
    find :all,                        
         :conditions => "active = true AND (name LIKE '%#{contact_info}%' OR email LIKE '%#{contact_info}%' OR description LIKE '%#{contact_info}%')",
         :order => "created_at DESC, title ASC"
  end

  def active_status
    active? ? "activated" : "deactivated"
  end
  
  protected 
  
  def end_date_cannot_be_in_the_past
    errors.add(:end_date, "can't be in the past") if !end_date.blank? and end_date < Date.today
  end
  
end
