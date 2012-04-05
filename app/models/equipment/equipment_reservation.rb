include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

# Models a reservation or current loan of equipment. Each reservation can have multiple pieces of equipment associated with it.
# 
# = Statuses
# 
# Each reservation is associated with a status that is based on a nunmber of factors:
# 
#   in_progress::       !submitted?
#   pending::           requires_approval? && submitted? && !approved?
#   approved::          (!requires_approval? OR (requires_approval? && approved?)) && submitted?
#   late::              checked_out? && Time.now > end_date
#   checked_out::       checked_out?
#   returned_late::     checked_in? && checked_in_at > end_date
#   returned_damaged::  checked_in? && !checkin_ok?
#   returned::          checked_in?
# 
# These statuses are computed when a reservation is saved, and stored in the +status+ attribute for quick retrieval.
class EquipmentReservation < ActiveRecord::Base
  include ActionController::UrlWriter

  AWAITING_APPROVAL_EMAIL_TEMPLATE = "Equipment Reservation Awaiting Approval"
  APPROVAL_REQUEST_EMAIL_TEMPLATE = "Equipment Reservation Approval Request"
  RESERVATION_APPROVED_EMAIL_TEMPLATE = "Equipment Reservation Approved"
  NO_APPROVAL_NEEDED_EMAIL_TEMPLATE = "Equipment Reservation Confirmed No Approval Needed"
  NO_APPROVAL_NEEDED_STAFF_EMAIL_TEMPLATE = "Equipment Reservation Confirmed No Approval Needed To Staff"

  LATE_NOTICE_EMAIL_TEMPLATE = "Equipment Reservation Late Notice"
  STAFF_LATE_NOTICE_EMAIL_TEMPLATE = "Equipment Reservation Late Notice To Staff"
  CHECKOUT_REMINDER_EMAIL_TEMPLATE = "Equipment Reservation Checkout Reminder"
  CHECKIN_REMINDER_EMAIL_TEMPLATE = "Equipment Reservation Checkin Reminder"
  NOT_READY_NOTICE_EMAIL_TEMPLATE = "Equipment Reservation Not Ready Notice"
  
  # The abbreviation of the unit that is the "catch-all" -- in this case, "EXP"
  NON_SPECIFIC_UNIT_ABBREVIATION = "EXP"
  
  # The default maximum days for checkout. Beyond this limit, reservations must be approved by someone.
  DEFAULT_MAX_CHECKOUT_DAYS = 14
  
  # The time that reservations are due back, in 24-hour format (e.g., "16:00:00" for 4 pm.)
  TIME_DUE_BACK = "16:00:00"

  # Defines the number of days that a student is restricted from reserving equipment depending on the lateness of a return.
  # Stored as a hash with keys of (number of days late) and values of (length of restriction).
  LATE_PENALTIES = {
    0 => 2.weeks,
    1 => 1.month,
    2 => 2.months,
    3 => 3.months
  }

  belongs_to :person
  belongs_to :unit
  belongs_to :approver, :class_name => "User", :foreign_key => 'approver_id'
  belongs_to :checkout_user, :class_name => "User", :foreign_key => 'checkout_user_id'
  belongs_to :checkin_user, :class_name => "User", :foreign_key => 'checkin_user_id'
  
  has_many :reservation_equipments, :class_name => "EquipmentReservationEquipment", :dependent => :destroy
  has_many :equipments, :through => :reservation_equipments do
    def in_category(category)
      find :all, :conditions => { :equipment_category_id => category.id }, :order => 'created_at DESC'
    end
    def in_as_same_category(as_same_category)
      find_all.select{|e| e.category.as_same_category == as_same_category}
    end
  end
  
  has_one :hold_token, :class_name => "Token", :as => :tokenable
  
  validates_presence_of :policy_agreement_date, 
                        :message => "You must agree to the policies before you reserve any equipment.", 
                        :unless => :staff?
  validates_presence_of :project_description, :if => :require_project_validations?, 
                        :message => "must be submitted before you can reserve any equipment.",
                        :unless => :staff?
  validates_presence_of :unit_id, 
                        :if => :require_project_validations?,
                        :unless => :staff?
  validates_numericality_of :length, :greater_than_or_equal_to => 0, :allow_nil => true, 
                        :message => "is invalid: the pickup date must be before the return date"
  
  validates_presence_of :checked_out_at, :checkout_id_verify, :checkout_user_id, :if => :validate_checkout?
  validates_presence_of :checked_in_at, :checkin_user_id, :if => :validate_checkin?
  validates_inclusion_of :checkin_ok, :in => [true, false], :if => :validate_checkin?
  
  before_save :update_status!
  
  after_save :generate_hold_token_if_needed
  
  attr_protected :staff
  
  default_scope :order => "start_date DESC"
  
  named_scope :submitted, :conditions => "status != 'in_progress'"
  named_scope :todays_checkouts, :conditions => "status = 'approved' AND TO_DAYS(start_date) = TO_DAYS(CURDATE())"
  named_scope :todays_checkins, :conditions => "(status = 'checked_out' OR status = 'late') AND TO_DAYS(end_date) = TO_DAYS(CURDATE())"
  named_scope :tomorrows_checkouts, :conditions => "status = 'approved' AND TO_DAYS(start_date) = TO_DAYS(adddate(curdate(),1))"
  named_scope :tomorrows_checkouts_excluding_weekends, :conditions => "status = 'approved' AND TO_DAYS(start_date) = TO_DAYS(adddate(curdate(),#{(Time.now.wday == 5 ? 3 : 1)}))"
  named_scope :tomorrows_checkins, :conditions => "(status = 'checked_out' OR status = 'late') AND TO_DAYS(end_date) = TO_DAYS(adddate(curdate(),1))"
  named_scope :late_returns, :conditions => "status = 'late'"
  named_scope :in_status, lambda { |status| { :conditions => { :status => status.to_s }}}
  
  # Returns a stringified version of the ID number, zero-padded to four digits.
  def id_s
    id.to_s.rjust(4, "0")
  end
  
  attr_accessor :require_project_validations
  def require_project_validations?
    require_project_validations
  end

  attr_accessor :require_equipment_validations
  def require_equipment_validations?
    require_equipment_validations
  end
  
  attr_accessor :validate_checkout
  def validate_checkout?
    validate_checkout
  end

  attr_accessor :validate_checkin
  def validate_checkin?
    validate_checkin
  end

  # Returns the status of this reservation (see intro for more details).
  def status(force = true)
    update_status! && save && reload if force || read_attribute(:status).blank?
    read_attribute(:status).to_sym
  end
  
  # Alias for #status(true)
  def status!
    status(true)
  end
  
  # Recalculates the status for this reservation based on the rules above.
  def update_status!
    s = case
    when !submitted?                                              then :in_progress
    when requires_approval? && submitted? && !approved?           then :pending
    when submitted? && approved? && !checked_out? && !checked_in? then :approved
    when checked_out? && late?                                    then :late
    when checked_out?                                             then :checked_out
    when checked_in? && late?                                     then :returned_late
    when checked_in? && !checkin_ok?                              then :returned_damaged
    when checked_in?                                              then :returned
    else                                                               :unknown
    end
    self.status = s.to_s
  end

  # Returns the number of days that this reservation lasts, or nil if start_date and end_date aren't defined yet.
  def length
    return nil if start_date.blank? || end_date.blank?
    ((end_date - start_date)/24/60/60).to_i
  end
  alias :length_before_type_cast :length

  # Returns a string representing the amount of the time the reservation lasts, like "2 weeks, 1 day"
  def length_in_words
    return "" if end_date.blank? || start_date.blank?
    return nil if length.nil?
    return "Same day checkout" if same_day_checkout?
    str = []
    weeks,days = length.divmod(7)
    str << "#{weeks} #{weeks > 1 ? 'weeks' : 'week'}" unless weeks.zero?
    str << "#{days} #{days > 1 ? 'days' : 'day'}" unless days.zero?
    str.join(", ")
  end

  # Returns the reservation details as a block of text that can be used in emails.
  def reservation_details_text_block(indent_spaces = 5, delimiter = "\n")
    details = []
    details << ["Reservation ID", id_s]
    details << ["Student", person.fullname]
    details << ["Pick up date", start_date.to_s(:date_with_day_of_week)]
    details << ["Return date", expected_time_due_back.to_s(:date_by_time12)]
    details << ["Length", length_in_words]
    # details << ["Project Description", h(project_description)]
    details << ["Unit Sponsor", unit.try(:name)]
    details << ["Equipment", equipments.collect(&:title).join(", ")]
    indent_text = " " * indent_spaces
  	details.collect{|d| indent_text.to_s + "#{d[0]}: ".ljust(22) + "#{d[1]}"}.join(delimiter)
  end

  # Returns true if the #length of this reservation is only 1 day.
  def same_day_checkout?
    length && length.zero?
  end

  # Adds or removes a piece of equipment from this reservation.
  def add_or_remove!(equipment)
    e = equipment.is_a?(Equipment) ? equipment : Equipment.find(equipment)
    if equipments.include?(e)
      return remove!(e)
    else
      return add!(e, true)
    end
  end

  # Removes a piece of equipment from this reservation, no questions asked.
  def remove!(e)
    equipments.delete(e)
  end
  
  # Adds a piece of equipment to this reservation if it's allowed. Also removes other equipments from this reservation
  # if adding this item would go over the +max_items_per_checkout+ for this item's category (e.g., if you're only allowed
  # to check out 2 flip cameras and you already have 2 on this reservation, then we'll remove one of the other flip cameras).
  # We use the #total_category_item_count here so that we're also checking this user's other overlapping reservations (if you)
  # have a reservation for 2 Flip cameras at the same time, then you shouldn't be able to checkout 2 more in this reservation
  # because you'd go over the total limit of 3). If this removal happens, we do not notify the user by default but if you pass
  # +true+ for the +add_errors+ parameter, then this notice will be added to this reservations +@errors+ base.
  def add!(e, add_errors = false)
    return false unless allows?(e, true)
    if e.category && total_category_item_count(e.category) >= e.category.max_items_per_checkout 
      deleted_e = e.category.as_same_category? ? equipments.in_as_same_category(e.category.as_same_category).first : equipments.in_category(e.category).first
      if deleted_e && !staff?
        equipments.delete(deleted_e)
        categor_title = e.category.as_same_category? ? e.category.as_same_category+" (Maximun allowed number: 1)" : e.category.title
        errors.add_to_base "We added #{e.title} to your reservation but had to remove 
                            #{deleted_e.title} because this would have put you over the
                            maximum allowed number of items from the #{categor_title} category." if add_errors
      end
    end
    equipments << e
    true
  end
  
  # Returns true if this reservation will allow this item to be added. Returns false if:
  # 
  # * This piece of equipment is already reserved for that time period (ueses Equipment#avilable_for?)
  # * Reservation window is longer than the +max_days_for_checkout+ for this equipment's category
  # * This person has another reservation during the same time period and the total items in the category between both
  #    reservations is greater than the +max_items_for_checkout+ for this equipment's category.
  # 
  # This method returns +true+ if the equipment is allowed to be added to this reservation. If not, it returns false. 
  # If you'd like to add descriptive errors to the reservation's +@errors+ object, pass true for the second parameter.
  def allows?(equipment, add_errors = false)
    unless equipment.available_for?(self)
      errors.add_to_base "#{equipment.title} is not available during the time period you selected." if add_errors
      return false
    end
    if equipment.category && !staff?
      if ((end_date - start_date)/24/60/60).to_i > equipment.category.max_checkout_days
        errors.add_to_base "#{equipment.title} can't be checked out for more 
                            than #{pluralize equipment.category.max_checkout_days, "day"}." if add_errors
        return false
      end
      if total_category_item_count(equipment.category) > equipment.category.max_items_per_checkout && !staff?
        errors.add_to_base "You have an overlapping reservation with items from the #{equipment.category.title} 
                            category and you've reached the limit of items from this category that you can check
                            out at the same time." if add_errors
        return false
      end
    end
    true
  end

  # Checks all equipment that has been added to this reservation and then removes any that are no longer allowed
  # based on #allowed?.
  def remove_disallowed_items!
    for equipment in equipments
      remove!(equipment) unless allows?(equipment, true)
    end
  end

  # Provides hash of dates that are possible for this reservation's end date, denoting weekends and holidays for disabling.
  # Uses the DEFAULT_MAX_CHECKOUT_DAYS constant to determine how far out to go. The hash includes two items:
  # 
  # * +:dates+ includes an array of arrays of dates and titles (useful for +options_for_select+)
  # * +:disabled+ includes an array of just the dates that aren't valid (holidays and weekends)
  # 
  # If +start_date+ hasn't been set yet, this method returns an empty set.
  def end_date_choices
    return { :dates => [], :disabled => [] } if start_date.nil?
    dates = []
    disabled = []
    for i in (DEFAULT_MAX_CHECKOUT_DAYS + 1).times
      d = start_date + i.days
      title = "#{d.to_s(:date_with_day_of_week)}"
      if i == 0
        title += " (Same Day Return)"
      elsif d.strftime("%w") == "0" || d.strftime("%w") == "6" # weekend
        disabled << d
      elsif d.to_date.is_holiday?
        title += " (Holiday)"
        disabled << d
      else
        title += " (#{pluralize(i, "day")})"
      end
      dates << [title, d.to_s(:db)]
    end
    return { :dates => dates, :disabled => disabled.collect{|d| d.to_s(:db) } }
  end
  
  # Sets the start_date and also resets the end_date to the next eligible date if the old end_date is now invalid.
  def start_date=(new_start_date)
    if start_date != new_start_date
      old_length = length
      self.write_attribute(:start_date, new_start_date)
      self.write_attribute(:end_date, (end_date_choices[:dates][old_length] || end_date_choices[:dates][1])[1]) if end_date && end_date_choices
    end
  end

  # Returns other submitted reservations by this person that overlap this reservation. Used for checking that a person doesn't
  # usurp the checkout limits by simply creating multiple overlapping reservations.
  def overlapping_reservations_for_person
    conditions = [['(start_date < :start_date AND end_date > :end_date)'],
                  ['(start_date < :end_date AND end_date > :end_date)'],
                  ['(start_date < :start_date AND end_date > :end_date)'],
                  ['(start_date > :start_date AND end_date < :end_date)']]
    @overlapping_reservations ||= person.equipment_reservations.find(:all, 
                                            :conditions => ["submitted = true 
                                            AND id != #{self.id}
                                            AND submitted = 1 
                                            AND (#{conditions.join(" OR ")})", 
                                            { :start_date => start_date, :end_date => end_date }])
  end
  
  # Returns a count of the number of items in this reservation that are part of the requested category.
  # Add check if category act as same (big) category, for example, laptop category for Macbook, HP, Dell, etc
  def category_item_count(category)
    c = category.is_a?(EquipmentCategory) ? category : EquipmentCategory.find(category)
    c.as_same_category? ? equipments.in_as_same_category(c.as_same_category).size : equipments.in_category(c).size      
  end

  # Returns the sum of the +category_item_count+s for all overlapping reservations for this person, plus the 
  # category_item_count for this reservation.
  def total_category_item_count(category)
    @total_category_item_count ||= overlapping_reservations_for_person.collect{|r| r.category_item_count(category)}.sum
    @total_category_item_count + category_item_count(category)
  end

  # Submits this reservation for approval:
  # 
  # * Send approval request email to staff users for selected program if reservation length is over DEFAULT_MAX_CHECKOUT_DAYS
  # * Send confirmation/pending email to student/person
  # * Marks +submitted+ as +true+.
  # 
  # Returns true on success or false otherwise.
  def submit!
    if requires_approval?
      @staff_template = EmailTemplate.find_by_name(APPROVAL_REQUEST_EMAIL_TEMPLATE)
      @student_template = EmailTemplate.find_by_name(AWAITING_APPROVAL_EMAIL_TEMPLATE)
    else
      @staff_template = EmailTemplate.find_by_name(NO_APPROVAL_NEEDED_STAFF_EMAIL_TEMPLATE)
      @student_template = EmailTemplate.find_by_name(NO_APPROVAL_NEEDED_EMAIL_TEMPLATE)
    end      
    send_staff_email!(@staff_template) if @staff_template && !staff?
    send_student_email!(@student_template) if @student_template
    
    self.update_attribute(:submitted, true)
  end

  # Returns true if the length of this checkout is longer than the DEFAULT_MAX_CHECKOUT_DAYS constant.
  def requires_approval?
    length > DEFAULT_MAX_CHECKOUT_DAYS
  end

  # Returns true if +approver_id+ and +approved_at+ are both not nil and this reservation requires approval.
  # If this reservation doesn't require approval (based on #requires_approval?), this method always returns true.
  def approved?
    return true if !requires_approval?
    !approver_id.nil? && !approved_at.nil?
  end

  # Returns true if there is a date in the +checked_in_at+ field.
  def checked_in?
    !checked_in_at.nil?
  end

  # Returns true if there is a date in the +checked_out_at+ field and +checked_in?+ is false.
  def checked_out?
    !checked_out_at.nil? && !checked_in?
  end

  # Returns true if the check-in time (+checked_in_at+) is after the TIME_DUE_BACK on the end_date of the reservation.
  def late?
    checked_in? ? (checked_in_at > expected_time_due_back) : (Time.now > expected_time_due_back)
  end

  # Returns the number of days this reservation is late, if it is late. Returns 0 for same-day lateness (returned after 4 pm).
  def days_late
    return nil unless late?
    compare_date = checked_in? ? checked_in_at : Time.now
    ((compare_date.to_date.to_time.to_i - end_date.to_date.to_time.to_i)/24/60/60).to_i
  end
  
  # Returns a Time object of the expected time this reservation is due back, based on the TIME_DUE_BACK constant. Or, if this
  # is a staff checkout, give the actual time from the end_date.
  def expected_time_due_back
    staff? ? end_date : Time.parse("#{end_date.to_date.to_s} #{TIME_DUE_BACK}")
  end
  
  def expected_time_due_back_pretty
    expected_time_due_back.to_s(:date_at_time12)
  end
  
  # Modifies the student's +equipment_reservation_restriction_until+ date based on the number of days this reservation is late.
  # Also adds a note to the student record. Returns nil if the reservation isn't late yet, or the new restriction date otherwise.
  def apply_late_penalties!
    return nil unless late?
    restriction_length = LATE_PENALTIES[days_late] || LATE_PENALTIES.max.last
    new_restriction_date = restriction_length.from_now
    person.update_attribute(:equipment_reservation_restriction_until, new_restriction_date)
    person.notes.create(:note => "Equipment reservation ##{id_s} returned late; reservation restriction imposed until #{new_restriction_date.to_s(:date_with_day_of_week)}.")
    return new_restriction_date
  end

  # Sends a notice to the student telling him that he is late returning the equipment.
  def send_late_notice!
    puts "Sending late notice to student (Reservation ##{id_s})" 
    send_student_email!(LATE_NOTICE_EMAIL_TEMPLATE)
  end
  
  # Sends a notice to the EXP staff and the unit staff telling them that a reservation is late.
  def send_staff_late_notice!
    puts "Sending late notice to staff (Reservation ##{id_s})" 
    send_staff_email!(STAFF_LATE_NOTICE_EMAIL_TEMPLATE, true)
  end
  
  # Sends a reminder to the student to remember to pickup their equipment tomorrow.
  def send_checkout_reminder!
    puts "Sending checkout reminder to student (Reservation ##{id_s})" 
    send_student_email!(CHECKOUT_REMINDER_EMAIL_TEMPLATE)
  end
  
  # Sends a reminder to the student to remember to return their equipment tomorrow.
  def send_checkin_reminder!
    puts "Sending check-in reminder to student (Reservation ##{id_s})" 
    send_student_email!(CHECKIN_REMINDER_EMAIL_TEMPLATE)
  end
    
  # Sends a notice to the EXP staff telling them that some of the equipment for this reservation isn't ready to go!
  def send_not_ready_notice!
    puts "Sending Not Ready Notice to staff (Reservation ##{id_s})" 
    send_staff_email!(NOT_READY_NOTICE_EMAIL_TEMPLATE, true)
  end  
  
  # Returns true if all of the equipment contained in this reservation is ready for checkout
  def ready_for_checkout?
    !equipments.collect(&:ready_for_checkout?).include?(false)
  end

  # Returns a link to the student's summary page for this reservation
  def summary_link
    url_for(:host => CONSTANTS[:base_url_host], :controller => 'equipment_reservation', :action => 'summary', :id => self.id)
  end

  # Returns the link that admin users can use to get directly to this application
  def admin_link
    equipment_reservation_url(self, :host => CONSTANTS[:base_url_host])
  end
  
  # In development, need to change path to "tmp/cahce/expo_current_checkout_viewing"
  CHECKOUT_VIEWING_CACHE_FILE = "/tmp/cache/expo_current_checkout_viewing" 

  # Stores this reservation as the checkout reservation that's currently being viewed. Useful for displaying on the
  # screen in the equipment closet. This is set when someone clicks the "Checkout" button anywhere in the system.
  def save_as_current_checkout_viewing
    File.open(CHECKOUT_VIEWING_CACHE_FILE, 'w') { |f| f.write(id) }
    true
  end
  
  # Clears the file that stores the current checkout view reservation. This happens when someone finishes a checkout.
  def self.clear_current_checkout_viewing!
    File.open(CHECKOUT_VIEWING_CACHE_FILE, 'w') { |f| f.write(nil) }
    true
  end
  
  # Fetches the reservation that's currently being viewed for checkout based on what's stored in the 
  # +/tmp/cache/expo_current_checkout_viewing+ file. If nothing is stored, returns nil.
  def self.current_checkout_viewing
    i = File.read(CHECKOUT_VIEWING_CACHE_FILE).to_i if File.exists?(CHECKOUT_VIEWING_CACHE_FILE)
    self.find(i) unless i.nil? || i.zero?
  end

  # The "hold token" is used when staff creates a reservation on behalf of a student -- the student then uses this
  # code to "claim" the reservation later.
  def generate_hold_token_if_needed
    # puts "Generating hold token for reservation #{id_s}"
    create_hold_token unless hold_token
  end
  
  protected
  
  def send_staff_email!(template, include_catchall_staff = false)
    template = EmailTemplate.find_by_name(template) if template.is_a?(String)
    return false if template.nil?
    users = unit.users_in_role(:equipment_reservation_approver) rescue []
    if include_catchall_staff
      catchall_unit = Unit.find_by_abbreviation(NON_SPECIFIC_UNIT_ABBREVIATION)
      users << catchall_unit.users_in_role(:equipment_reservation_approver) if catchall_unit
    end
    return false if users.empty?
    TemplateMailer.deliver(template.create_email_to(self, nil, users.flatten.collect(&:email).uniq.join(", ")))
  end

  def send_student_email!(template)
    template = EmailTemplate.find_by_name(template) if template.is_a?(String)
    return false if template.nil?
    EmailContact.log(
      person_id, 
      TemplateMailer.deliver(template.create_email_to(self)), 
      nil, nil, 
      self
    )
  end

end
