# Models a single time instance of an Event. See details at Event for details of this relationship.
class EventTime < ActiveRecord::Base
  stampable
  belongs_to :event
  belongs_to :location
  has_many :invitees, :class_name => "EventInvitee", :dependent => :destroy
  has_many :attendees, :class_name => "EventInvitee", :conditions => { :attending => true }, :dependent => :destroy
  has_many :attended, :class_name => "EventInvitee", :conditions => "checkin_time IS NOT NULL"
  has_many :sub_times, :class_name => "EventSubTime", :foreign_key => "parent_time_id"
  
  validates_presence_of :event_id, :start_time

  PLACEHOLDER_CODES = %w( time_detail time_only notes location_text )
  PLACEHOLDER_ASSOCIATIONS = %w( event location )

#  named_scope :all, :conditions => { :parent_time_id => nil }

  def <=>(o)
    start_time <=> o.start_time rescue 0
  end

  # Returns true if this event time is in the past. If end_time is defined, we use that for the comparison; otherwise start_date.
  def past?
    return Time.now > end_time if end_time
    Time.now > start_time
  end
  
  def attendee_list
    list = []
    attendees.each{|a| list << a.person.fullname unless a.person.nil? }
    list.join(", ")
  end
  
  # Returns true if this event time is full. An event time is full if adding another attendee to the EventTime would cause
  # the EventTime to be over capacity (as defined by <tt>EventTime#capacity</tt>). Or, if <tt>Event#capacity</tt> is defined, 
  # then we base this calculation off whichever number is less. This allows you to define an event, say, where each timeslot can
  # only support 5 attendees each and all of the timeslots cannot total more than 50 attendees.
  # 
  # Note that this method does *not* take into account invitee guests (<tt>EventInvitee#number_of_guests</tt>).
  def full?
    if capacity.to_i.zero? # unlimited cap for this timeslot; check if there is an event-wide cap
      return event.capacity.to_i.zero? ? false : event.attendees.size >= event.capacity
    else # there is a timeslot cap; check both timeslot count and event-wide count
      return attendees.size >= capacity ? true : event.attendees.size >= (event.capacity.to_i.zero? ? 1e5 : 0)
    end
  end
  
  # Opposite of <tt>full?</tt>.
  def open?
    !full?
  end

  # Returns the number of slots left available for this time slot. Note: this method does *not* take into consideration the
  # Event's capacity (like +full?+ does); instead, it only looks at this EventTime's capacity.
  def slots_left
    capacity.to_i.zero? ? nil : capacity - attendees.size
  end
  
  # Creates a new EventInvitee record for this event time, or updates an existing record if one already exists for this +obj+. 
  # Pass the object and an optional hash of extra attributes for the new EventInvitee object. Returns the new EventInvitee object.
  def invite!(obj, invitee_attributes = {})
    return nil if obj.nil?
    invitee = find_invitee(obj)
    if invitee.nil?
      invitee_attributes.merge!(:invitable => obj)
      invitee = invitees.create(invitee_attributes)
    else
      invitee.update_attributes(invitee_attributes)
    end
    invitee
  end
  
  # Returns true if the object already has an EventInvitee object in this EventTime's list of invitees.
  def invited?(obj)
    return false if obj.nil?
    find_invitee(obj).nil?
  end

  # Returns true if the object already has an EventInvitee object in this EventTime's list of invitees and +attending+ is +true+.
  def attending?(obj)
    return false if obj.nil?
    invitee = find_invitee(obj)
    invitee.nil? ? false : invitee.attending?
  end

  # Finds an EventInvitee object for this obj, if it exists, or nil.
  def find_invitee(obj)
    return nil if obj.nil?
    klass = obj.class.respond_to?(:parent_class) ? obj.class.parent_class.to_s : obj.class.to_s
    invitees.find_by_invitable_type_and_invitable_id(klass, obj.id)
  end

  # Convenience method for +time_detail(:time_only => true)+
  def time_only
    time_detail(:time_only => true)
  end

  # Returns a human-readable bit of text describing the start and end times of this event, as follows:
  # 
  # * If no +end_time+ is defined, then simply state the date and start time: <tt>(date) at (start_time)</tt>
  # * If an +end_time+ is defined and the dates for both the start and end are the same: <tt>(date) from (start_time) to (end_time)</tt>
  # * If +end_time+ is on a different date than +start_time+: <tt>(start_date) at (start_time) to (end_date) at (end_time)</tt>
  # 
  # *Options*
  # 
  # Allowable options include:
  # 
  # * +use_words+: Use words like "from" and "at" instead of a hyphen or a space. Defaults to true.
  # * +date_format+: Format to use for date portions. Defaults to +date_with_day_of_week+.
  # * +time_format+: Format to use for time portions. Defaults to +time12+.
  # * +time_only+: Don't show the date, just the time(s).
  # * +date_only+: Don't show the times, just the date.
  # * +use_relative_dates+: Use "today" and "tomorrow" where applicable. Defaults to +true+.
  def time_detail(options = {})
    default_options = { 
      :use_words => true, 
      :date_format => :date_with_day_of_week, 
      :time_format => :time12, 
      :use_relative_dates => true 
    }
    options = default_options.merge(options)
    separator = options[:use_words] ? { :to => " to", :from => " from", :at => " at" } : { :to => " -", :from => "", :at => "" }
    _start_date = start_time.to_date.to_s(options[:date_format]).strip if start_time
    _start_date = "Today" if start_time.to_date == Time.now.to_date && start_time && options[:use_relative_dates]
    _start_date = "Tomorrow" if start_time.to_date == 1.day.from_now.to_date && start_time && options[:use_relative_dates]
    _start_time = start_time.to_time.to_s(options[:time_format]).strip if start_time
    _end_date = end_time.to_date.to_s(options[:date_format]).strip if end_time
    _end_date = "today" if end_time && end_time.to_date == Time.now.to_date && options[:use_relative_dates]
    _end_date = "tomorrow" if end_time && end_time.to_date == 1.day.from_now.to_date && options[:use_relative_dates]
    _end_time = end_time.to_time.to_s(options[:time_format]).strip if end_time
    return "#{_start_date}" if options[:date_only] && (end_time.blank? || start_time.to_date == end_time.to_date)
    return "#{_start_time}" if options[:time_only] && !end_time
    return "#{_start_time}#{separator[:to]} #{_end_time}" if options[:time_only] && start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}" if end_time.nil?
    return "#{_start_date}#{separator[:from]} #{_start_time}#{separator[:to]} #{_end_time}" if start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}#{separator[:to]} #{_end_date}#{separator[:at]} #{_end_time}"
  end


end
