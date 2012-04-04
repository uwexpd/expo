# Models a single time shift for a EventStaffPosition.
class EventStaffPositionShift < ActiveRecord::Base
  stampable
  belongs_to :position, :class_name => "EventStaffPosition", :foreign_key => "event_staff_position_id"
  has_many :staffs, :class_name => "EventStaff"
  has_many :people, :through => :staffs, :source => :person
  
  validates_presence_of :event_staff_position_id, :start_time
  
  delegate :event, :title, :to => :position

  PLACEHOLDER_CODES = %w( time_detail details )
  PLACEHOLDER_ASSOCIATIONS = %w( event position )
  
  def <=>(o)
    start_time <=> o.start_time rescue 0
  end
  
  # Returns a human-readable bit of text describing the start and end times of this shift. Uses the same options as
  # Event#time_detail.
  def time_detail(options = {})
    options = { :use_words => true, :date_format => :date_with_day_of_week, :time_format => :time12 }.merge(options)
    separator = options[:use_words] ? { :to => " to", :from => " from", :at => " at" } : { :to => " -", :from => "", :at => "" }
    _start_date = start_time.to_date.to_s(options[:date_format]).strip if start_time
    _start_date = "Today" if start_time.to_date == Time.now.to_date && start_time
    _start_date = "Tomorrow" if start_time.to_date == 1.day.from_now.to_date && start_time
    _start_time = start_time.to_time.to_s(options[:time_format]).strip if start_time
    _end_date = end_time.to_date.to_s(options[:date_format]).strip if end_time
    _end_date = "today" if end_time && end_time.to_date == Time.now.to_date
    _end_date = "tomorrow" if end_time && end_time.to_date == 1.day.from_now.to_date
    _end_time = end_time.to_time.to_s(options[:time_format]).strip if end_time
    return "#{_start_date}" if options[:date_only] && (end_time.nil? || start_time.to_date == end_time.to_date)
    return "#{_start_time}" if options[:time_only] && (end_time.nil?)
    return "#{_start_time}#{separator[:to]} #{_end_time}" if options[:time_only] && !end_time.nil? && start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}" if end_time.nil?
    return "#{_start_date}#{separator[:from]} #{_start_time}#{separator[:to]} #{_end_time}" if start_time.to_date == end_time.to_date
    return "#{_start_date}#{separator[:at]} #{_start_time}#{separator[:to]} #{_end_date}#{separator[:at]} #{_end_time}"
  end

  # Signs up a person for this shift. Specify false for the second parameter to not send an email.
  def signup!(person, send_email = true)
    new_staff = staffs.create(:person_id => person.id)
    new_staff.send_staff_signup_email if new_staff.valid? && send_email
    new_staff
  end
  
  # Un-signs up a person for this shift.
  def unsignup!(person)
    staffs.find_by_person_id(person.id).delete
  end
  
  # Returns true if the person is signed up for this shift.
  def signed_up?(person)
    people.include?(person)
  end

  # Returns an array of the other shifts for this event that this shift overlaps with timewise. Shifts are only evaluated if they
  # have a start time and an end time. Note that shifts that start and end at the same time (e.g., 1:30 pm) are *not* considered
  # to be overlapping by this function (this is done by substracting 1 second from all of the end times when comparing).
  def overlapping_shifts
    overlaps = []
    for other in event.staff_position_shifts.reject{|s| s == self}
      if start_time && end_time && other.start_time && other.end_time
        range = start_time..end_time-1.second
        if range.include?(other.start_time) || range.include?(other.end_time-1.second)
          overlaps << other
        end
      end
    end
    overlaps
  end

  # Returns true if +overlapping_shifts+ is not empty.
  def overlaps_other_shifts?
    !overlapping_shifts.empty?
  end

end
