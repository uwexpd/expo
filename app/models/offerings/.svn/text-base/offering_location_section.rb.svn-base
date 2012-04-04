class OfferingLocationSection < ActiveRecord::Base
  stampable
  belongs_to :offering
  has_many :presenters, :class_name => "ApplicationForOffering", :foreign_key => 'location_section_id'
  
  validates_presence_of :offering_id
  validates_presence_of :title
  
	def color=(new_color)
		new_color = nil if new_color.upcase.strip == "FFFFFF"
		self.write_attribute(:color, new_color)
	end
end
