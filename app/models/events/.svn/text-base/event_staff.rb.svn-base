# Each Event can have staff members (often volunteers). If a Person has a record in this table, then they have signed up to be an EventStaff for this Event. This association happens via EventStaffPositionShift, which identifies the possible different positions someone can sign up for.
class EventStaff < ActiveRecord::Base
  stampable
  belongs_to :shift, :class_name => "EventStaffPositionShift", :foreign_key => "event_staff_position_shift_id"
  belongs_to :person
  
  validates_presence_of :event_staff_position_shift_id, :person_id
  validates_uniqueness_of :person_id, :scope => :event_staff_position_shift_id

  validate :no_overlapping_times
  # If the time for this shift overlaps with another shift for this event that this person is signed up for, then return an error.
  def no_overlapping_times
    return true unless shift.overlaps_other_shifts?
    for other in shift.overlapping_shifts
      errors.add_to_base "This shift overlaps with #{other.position.title} shift #{other.time_detail}" if other.signed_up?(person)
    end
  end

  delegate :position, :to => :shift
  delegate :event, :to => :position
  
  PLACEHOLDER_CODES = %w( )
  PLACEHOLDER_ASSOCIATIONS = %w( person shift event position )
    
  # Sends a confirmation email to the volunteer using the +staff_signup_email_template+ as defined in the Event.
  # Returns the TMail object if successful or nil otherwise.
  def send_staff_signup_email
    return nil unless event.staff_signup_email_template
    if person
      email = event.staff_signup_email_template.create_email_to(self)
      EmailContact.log(person, TemplateMailer.deliver(email))
      return email
    end
    nil
  end
  
  
end
