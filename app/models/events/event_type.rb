class EventType < ActiveRecord::Base

	has_many :events, :class_name => "Event", :foreign_key => "event_type_id"

	validates_presence_of :title

  default_scope :order => "title"
	
	def <=>(o)
		title <=> o.title rescue 0
	end
	
end
