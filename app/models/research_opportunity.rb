class ResearchOpportunity < ActiveRecord::Base
  
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :title
  validates_presence_of :department
  validates_presence_of :description
  validates_presence_of :requirements
  validates_presence_of :research_area1  
        
  def get_area_name(area_id)
    ResearchArea.find(area_id).name rescue nil
  end
  
end
