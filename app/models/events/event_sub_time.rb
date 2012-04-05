class EventSubTime < EventTime
  stampable
  belongs_to :parent_time, :class_name => "EventTime", :foreign_key => "parent_time_id"
  validates_presence_of :parent_time_id
  
  def attendees
    parent_time.attendees.find :all, :conditions => { :sub_time_id => id}
  end

end