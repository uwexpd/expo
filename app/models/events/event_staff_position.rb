# Models a position that an EventStaff can sign up for. For example, "Session Assistant" or "Greeter" or something similar. Each Position can have multiple "shifts," modeled by the EventStaffPositionShift object. These shifts allow a person to choose one or multiple shifts to work. If the +require_all_shifts+ boolean is true, then users must sign up for _all_ shifts, not just one.
class EventStaffPosition < ActiveRecord::Base
  stampable
  belongs_to :event
  belongs_to :training_session_event, :class_name => "Event", :foreign_key => "training_session_event_id"
  has_many :shifts, :class_name => "EventStaffPositionShift"
  
  validates_presence_of :event_id, :title
  
  PLACEHOLDER_CODES = %w( title description instructions capacity )
  PLACEHOLDER_ASSOCIATIONS = %w( event )
  
  def <=>(o)
    title <=> o.title rescue 0
  end
  
  # Signs up a person for this position. If there are multiple shifts, signs them up for all of them.
  def signup!(person)
    new_shifts = shifts.collect{|shift| shift.signup!(person)}
    new_shifts.each{|shift| shift.delete } if new_shifts.collect(&:valid?).include?(false)
    new_shifts
  end

  # Un-signs up a person for this position. If there are multiple shifts, un-signs them up for all of them.
  def unsignup!(person)
    shifts.collect{|shift| shift.unsignup!(person)}
  end
  
  # Returns true if the person is signed up for *any* shifts for this position.
  def signed_up?(person)
    shifts.collect{|shift| shift.signed_up?(person)}.include?(true)
  end
  

end
