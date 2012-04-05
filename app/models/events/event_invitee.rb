# Models someone (or something) that has been invited to an event. The person is not necessarily attending the event if they have a record in this table. They are only attending if +attending+ is +true+. This allows you to keep track of people who RSVP "no" and collect other useful information from non-attendees, like comments.
# 
#   This object is modeled with a polymporphic association so that any object can be invited to and attend an Event. Usually this will be a Person, but it could also be other Person-related objects like an OrganizationContact (or an entire Organization, potentially) or an ApplicationForOffering.
class EventInvitee < ActiveRecord::Base
  stampable
  belongs_to :event_time
  belongs_to :invitable, :polymorphic => true
  belongs_to :sub_time, :class_name => "EventTime", :foreign_key => "sub_time_id"
  belongs_to :person
  
  validates_presence_of :event_time_id, :invitable_type, :invitable_id
  
  delegate :event, :to => :event_time
  delegate :firstname, :lastname, :firstname_first, :lastname_first, :fullname, :to => :invitable
  
  PLACEHOLDER_CODES = %w( rsvp_comments )
  PLACEHOLDER_ASSOCIATIONS = %w( person event event_time sub_time )

  before_save :cache_person_id

  def <=>(o)
    invitable <=> o.invitable rescue 0
  end
  
  # Sends a confirmation email to the invitee using the +confirmation_email_template+ as defined in the Event.
  # Returns the TMail object if successful or nil otherwise.
  def send_confirmation_email
    return nil unless event.confirmation_email_template
    if person
      email = event.confirmation_email_template.create_email_to(self)
      EmailContact.log(person, TemplateMailer.deliver(email))
      return email
    end
    nil
  end
  
  def cache_person_id
    p = invitable.is_a?(Person) ? invitable : (invitable.respond_to?(:person) ? invitable.person : nil)
    self.person_id = p.try(:id)
  end
  
  def email
    person.nil? ? nil : person.email
  end

  # Tries to find an ApplicationForOffering object for this invitee. If this object's invitable is an ApplicationForOffering,
  # then return that. Otherwise, look through the applications for this event's offering (if it has one).
  def application_for_offering
    return invitable if invitable.is_a?(ApplicationForOffering)
    return invitable.app if invitable.is_a?(ApplicationGroupMember)
    return nil if event.offering.nil?
    ApplicationForOffering.find_by_person_id_and_offering_id(person.id, event.offering.id)
  end

  # Returns true if there is a value in the +checkin_time+ field.
  def checked_in?
    !checkin_time.blank?
  end
  
  # Checks in this invitee (in other words, mark that this invitee attended the event). By default, we use the current time, bu
  # you can override it by specifying a different time.
  def checkin!(time = Time.now)
    update_attribute(:checkin_time, time)
  end
  
end
