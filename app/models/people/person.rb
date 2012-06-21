class Person < ActiveRecord::Base
  stampable
  include ActionView::Helpers::NumberHelper
  include ActionController::UrlWriter
  
  PIPELINE_ORIENTATION_EXPIRATION = 2.year
  
  belongs_to :department
  belongs_to :institution
  belongs_to :class_standing, :class_name => "ClassStanding", :foreign_key => "class_standing_id"
  before_create :generate_token
  
  has_many :pipeline_positions_favorites
  has_many :pipeline_favorites, :through => :pipeline_positions_favorites, :source => :service_learning_position

  has_many :users
  has_many :application_for_offerings do
    def past
      all.select{|a| a.offering.past? }
    end
    def current
      all.select{|a| a.offering.current? }
    end
    def open
      all.select{|a| a.offering.open? }
    end
    def closed
      all.select{|a| !a.offering.open? }
    end
  end
  belongs_to :estimated_graduation_quarter, :class_name => "Quarter", :foreign_key => "est_grad_qtr"
  has_many :application_mentors
  has_many :mentee_applications, :through => :application_mentors, :source => :application_for_offering
  has_many :offering_reviewers
  has_many :offering_interviewers
  has_many :organization_contacts, :conditions => { :current => true }
  has_many :organizations, :through => :organization_contacts
  has_many :former_organization_contacts, :class_name => "OrganizationContact", :conditions => { :current => false }
  has_many :former_organizations, :through => :former_organization_contacts
  has_many :service_learning_course_instructors
  has_many :service_learning_courses, :through => :service_learning_course_instructors do
    def for(quarter)
      find(:all, :conditions => ['quarter_id = ?', quarter.id])
    end
  end
  belongs_to :service_learning_risk_placement, :class_name => "ServiceLearningPlacement", :foreign_key => "service_learning_risk_placement_id"

  has_many :notes, :as => :notable, :dependent => :nullify
  has_many :event_invites, :class_name => "EventInvitee", :as => :invitable, :dependent => :destroy
  
  has_many :committee_members
  has_many :committees, :through => :committee_members
  has_many :contact_histories, :order => 'updated_at DESC'
  has_many :event_staffs
  has_many :event_staff_shifts, :through => :event_staffs, :source => :shift do
    def for(position); find(:all, :conditions => ['event_staff_position_id = ?', position.id]); end
  end

  def event_staff_positions(event)
    event_staffs.find_all{|s| s.event == event}.collect(&:position).flatten.uniq
  end

  has_many :equipment_reservations do
    def submitted; find(:all, :conditions => { :submitted => true }); end
    def current; find(:all, :conditions => { :submitted => true, :checked_in_at => nil }); end
    def today; find(:all, :conditions => "(status = 'approved' AND TO_DAYS(start_date) = TO_DAYS(CURDATE()))
                                            OR status = 'checked_out' OR status = 'late'"); end
    def past; find(:all, :conditions => "checked_in_at IS NOT NULL" ); end
  end
  
  has_many :appointments, :foreign_key => 'staff_person_id' do
    def today; find(:all, :conditions => "DATE(start_time) = '#{Time.now.to_date}'"); end
    def yesterday; find(:all, :conditions => "DATE(start_time) = '#{1.day.ago.to_date}'"); end
    def tomorrow; find(:all, :conditions => "DATE(start_time) = '#{1.day.from_now.to_date}'"); end
  end
  
  has_one :pipeline_student_info

  # validates_presence_of :salutation, :if => :require_validations?
  validates_presence_of :firstname, :if => :require_validations?
  validates_presence_of :firstname, :if => :require_name_validations?
  validates_presence_of :lastname, :if => :require_validations?
  validates_presence_of :lastname, :if => :require_name_validations?
  validates_presence_of :email, :if => :require_validations?
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :require_validations?
  validates_presence_of :address1, :if => :require_address_validations?
  validates_presence_of :city, :if => :require_address_validations?
  validates_presence_of :state, :if => :require_address_validations?
  validates_presence_of :zip, :if => :require_address_validations?
  validate :student_validations, :if => :require_student_validations?
#  validates_inclusion_of :gender, :in => ['M','F',nil]

  has_many :service_learning_placements do
    # Limit results to placements that are specifically connected to the supplied object. Object can be a Quarter, a 
    # ServiceLearningPosition, or a ServiceLearningCourse.
    def for(obj, unit = Unit.find_by_abbreviation("carlson"))
      if unit.nil?
        u = Unit.find_by_abbreviation("pipeline")
        conditions = [" organization_quarters.quarter_id = ? AND organization_quarters.unit_id != ?", obj.id, u.id]
      else
        conditions = [" organization_quarters.quarter_id = ? AND organization_quarters.unit_id = ? ", obj.id, unit.id]
      end
      if obj.is_a? Quarter
        find(:all, 
             :conditions => conditions,
             :include => {:position => {:organization_quarter => :organization}})
      else
        find(:all, 
            :conditions => ["#{obj.class.name.foreign_key} = ? AND organization_quarters.unit_id = ? ", obj, unit.id], 
            :include => {:position => {:organization_quarter => :organization}}) rescue []
      end
    end
  end
  
  has_many :pipeline_placements, :class_name => "ServiceLearningPlacement", 
           :include => {:position => {:organization_quarter => :organization}},
           :conditions => [" organization_quarters.unit_id = :unit_id OR service_learning_placements.unit_id = :unit_id ", 
                            {:unit_id => Unit.find_by_abbreviation("pipeline")}] do
    # Limit to the passed quarter
    def for(quarter, unit = Unit.find_by_abbreviation("pipeline"))
      if quarter.is_a? Quarter
        find(:all, 
             :conditions => [" organization_quarters.quarter_id = :quarter_id AND 
                               (organization_quarters.unit_id = :unit_id OR
                                service_learning_placements.unit_id = :unit_id) ", 
                               {:quarter_id => quarter.id, :unit_id => unit.id}],
             :include => {:position => {:organization_quarter => :organization}})
      else
        return nil
      end
    end
    
  end
  
  has_many :course_extra_enrollees, :dependent => :destroy do
    def for(qtr)
      find(:all, :conditions => { :ts_year => qtr.year, :ts_quarter => qtr.quarter_code_id })
    end
  end
  has_many :service_learning_course_extra_enrollees, :include => :service_learning_course
  has_many :extra_service_learning_courses, 
            :class_name => "ServiceLearningCourse", 
            :through => :service_learning_course_extra_enrollees,
            :source => :service_learning_course
  
  before_update :update_timestamp
  def update_timestamp
    self.contact_info_updated_at = Time.now if self.changed?
  end
  
  named_scope :non_student, :conditions => { :type => nil }
  
  has_one :pipeline_token, :class_name => "Token", :as => :tokenable

  PLACEHOLDER_CODES = %w(fullname formal_fullname firstname lastname his_her him_her he_she email salutation formal_greeting
                          class_standing_description majors_list institution_name awards_list pipeline_email_stop)
  PLACEHOLDER_ASSOCIATIONS = %w()

  attr_accessor :require_validations, :require_name_validations, :require_address_validations, :require_student_validations
  
  def require_validations?
    require_validations
  end
  
  def require_name_validations?
    return false if self.is_a?(Student)
    require_name_validations
  end
  
  def require_address_validations?
    return false if self.is_a?(Student)
    require_address_validations
  end
  
  def require_student_validations?
    return false if self.is_a?(Student)
    require_student_validations
  end
  
  def student_validations
    unless self.is_a?(Student)
      errors.add :major_1, "can't be blank" if major_1.blank?
      errors.add :institution_id, "can't be blank" if institution_id.nil?
      errors.add :class_standing_id, "can't be blank" if class_standing_id.nil?
    end
  end
  
  def <=>(o)
    lastname_first <=> o.lastname_first
  end
  
  def fullname
    if fullname_unknown?
      email.blank? ? "(Name unknown)" : "#{email}"
    else
      "#{firstname} #{lastname}"
    end
  end
  
  alias_method :identifier_string, :fullname
  
  def fullname_unknown?
    firstname.nil? && lastname.nil?
  end
  
  def formal_fullname
    salutation.blank? ? "#{fullname}" : "#{salutation} #{fullname}"
  end
  
  def lastname_first(formal = true)
    "#{lastname}, #{formal ? formal_firstname(true) : firstname}" # rescue "(name unknown)"
  end
  
  def formal_firstname(include_nickname = false)
    include_nickname ? "#{firstname}#{" (" + nickname.strip + ")" unless nickname.blank?}" : firstname
  end
  
  def firstname_first(formal = true)
    "#{formal ? formal_firstname(true) : firstname} #{lastname}"
  end
  
  # Returns this person's nickname, unless the nickname is the exact same as the firstname (in which case, return nil).
  def nickname
    formal_firstname(false) == read_attribute(:nickname) ? nil : read_attribute(:nickname)
  end
  
  # Splits a fullname into firstname and lastname.
  def self.get_first_and_last(n)
    n.split.values_at(0,-1) rescue [nil,nil]
  end
  
  def formal_greeting
    salutation.blank? ? "#{fullname}" : "#{salutation} #{lastname}"
  end
  
  def department_name
    department.nil? ? other_department : department.department_full_name
  end
  
  def generate_token
    @attributes['token'] = Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{object_id}"))[0..7]
  end
  
  def phone=(number)
    write_attribute :phone, number.to_s.gsub(/\D/,"")
  end
  
  def fax=(number)
    write_attribute :fax, number.to_s.gsub(/\D/,"")
  end
    
  def phone_formatted
    number_to_phone(read_attribute(:phone))
  end
  
  # def phone
  #   phone_formatted
  # end
  
  def fax_formatted
    number_to_phone(fax)
  end

  # Returns a formatted address block for this person, including name. Depending on whether or not this person has a custom address 
  # block defined in the +address_block+ attribute, this method will either construct an address block from the other address details
  # or simply return the custom address block from the database. If this person has a box number defined, then we simply return the 
  # name and box number.
  def address_block(delimiter = "\n", options = {})
    return read_attribute(:address_block) unless read_attribute(:address_block).blank?
    a = "#{formal_fullname}"
    if box_no.blank?
      a << "#{delimiter}#{address1}"
      a << "#{delimiter}#{address2}" unless address2.blank?
      a << "#{delimiter}#{address3}" unless address3.blank?
      a << "#{delimiter}" unless city.blank? || state.blank? || zip.blank?
      a << "#{city}" unless city.blank?
      a << ", " unless city.blank? && state.blank?
      a << "#{state} "
      a << "#{zip}"
    else
      a << "#{delimiter}Box #{box_no}"
    end
    a
  end
  
  # Based on gender, returns a "his" or "her." If gender is not specified, returns "his or her."
  def his_her
    gender.blank? ? "his or her" : gender == "F" ? "her" : "his"
  end
  
  # Based on gender, returns a "he" or "she." If gender is not specified, returns "he or she."
  def he_she
    gender.blank? ? "he or she" : gender == "F" ? "she" : "he"
  end
  
  # Based on gender, returns a "him" or "her." If gender is not specified, returns "him or her."
  def him_her
    gender.blank? ? "him or her" : gender == "F" ? "her" : "him"
  end
  
  # Returns true if the students has been placed into a ServiceLearningPlacement for a given ServiceLearningCourse.
  def placed_for?(service_learning_course)
    !service_learning_placements.for(service_learning_course).empty?
  end

  # Places this person into the specified position for the specified course. Pass +true+ for the third parameter to also
  # update the date that this person submitted a risk waiver form. By default, this method sends the confirmation email to the student
  # at the end; pass +false+ as the fourth paramater to reverse this behavior.
  def place_into(position, service_learning_course, unit = nil, update_service_learning_risk_paper_date = false, send_confirmation_email = "1")
    ServiceLearningPlacement.transaction do
      # add pessimistic locking to prevent two students get same placement      
      @placement = position.placements.open_for(service_learning_course).first.lock! rescue nil
      if @placement
        @placement.update_attribute :person_id, self.id
        @placement.update_attribute :unit_id, unit.nil? ? position.unit_id : unit.id
        update_attribute :service_learning_risk_placement_id, @placement.id
        update_attribute :service_learning_risk_paper_date, Time.now if update_service_learning_risk_paper_date == "1"
        if send_confirmation_email == "1" && position.try(:unit).try(:bothell?)
          EmailContact.log self.id, ServiceLearningMailer.deliver_bothell_registration_complete(@placement) 
        elsif send_confirmation_email == "1"
          EmailContact.log self.id, ServiceLearningMailer.deliver_registration_complete(@placement) 
        elsif send_confirmation_email == "2"
          EmailContact.log self.id, ServiceLearningMailer.deliver_pipeline_registration_complete(@placement)
        end
      end
    end
    true
  end
  
  # Uses the place_into function but adds the ability to create a placement if it should
  def place_into!(position, service_learning_course, unit = nil, update_service_learning_risk_paper_date = false, send_confirmation_email = "1", force = true)
    ServiceLearningPosition.transaction do
      if force
        service_learning_course_id = service_learning_course.nil? ? nil : service_learning_course.id
        position.placements.create(:service_learning_course_id => service_learning_course_id)
        position = position.reload
      end    
      return place_into(position, service_learning_course, unit, update_service_learning_risk_paper_date, send_confirmation_email)
    end
  end
  
  # Returns an array of this person's majors, based on the "major_n" fields in the person record. Used for non-UW students.
  def majors
    [major_1, major_2, major_3].delete_if{|m| m.blank?}
  end
  
  # Constructs a printable list of majors based on the three "major_n" fields in the person record. Used for non-UW students.
  # The syntax of this method matches that in Student, but because we store major names as text only in the Person record, the
  # +show_full_names+ parameter is ignored.
  def majors_list(show_full_names = false, join_string = ", ", reference_quarter = nil)
    majors.join(join_string)
  end
  
  def class_standing_description(opts = {})
    class_standing.description unless class_standing.nil?
  end
 
  # For non-Students, we don't know, so we pass "unknown"
  def gpa
    "unknown"
  end
  
  # For non-Students, we don't know, so we return +NaN+.
  def gpa
    0.0/0.0
  end
 
  def institution_name
    read_attribute(:institution_name).blank? ? (institution.name unless institution.nil?) : read_attribute(:institution_name)
  end

  def transfer_student?
    false
  end
  
  def washington_state_resident?
    false
  end

  def earned_award?(award_type)
    awards.include?(award_type)
  end
  
  # Retrieves the award_type objects of awards that this student has earned. This is not a normal association because
  # awards earned are stored in the +award_ids+ attribute as space-separated ID values instead of proper DB objects.
  # TODO: Change this to a real association!
  def awards
    return [] if award_ids.nil?
    AwardType.find(award_ids.split)
  end
  
  # Converts the array of award_ids into a space-separated string for storage.
  def award_ids=(ids)
    return nil unless ids.is_a?(Hash)
    self.write_attribute(:award_ids, ids.keys.join(" "))
  end
  
  # Constructs a list of awards based on the "award_ids" field in the person record.
  def awards_list(join_string = ", ")
    return "" if awards.empty?
    awards.collect(&:scholar_title).join(join_string)
  end

  # Returns true if this person's contact information was updated since the specified time, according to
  # the +contact_info_updated_at+ attribute of this Person.
  def contact_info_updated_since(t)
    return false if contact_info_updated_at.nil?
    t < contact_info_updated_at
  end

  # Tries to find a person using the information passed to it. If a good match can't be found, we create
  # a new Person using the information passed. The only paramater is the hash of attributes to search and/or
  # create the record with.
  # 
  # Notes:
  # 
  #  * This method ONLY searches non-Students (records with a +type+ equal to +nil+).
  #  * Include :debug => true in the list of attributes to print out progress info.
  #  * E-mail is used as the primary search term.
  #  * If multiple records are found with an email search, we try to find a match on name.
  #  * If multiple records still exist, then use the newest record (based on updated_at).
  #  * If email is not given to search with, we look for an exact firstname/lastname match and return that record
  #     ONLY if there is only a single result. Otherwise, don't take chances and create a new one.
  #  * If nothing can be found, we create a new record using the information passed.
  #  * Validations are skipped when creating a new record, allowing minimal data to still create a record.
  def self.find_or_create_by_best_guess(attrs = {})
    @debug = attrs.delete(:debug) || false
    return nil if attrs.empty?
    
    person = Person.find_by_best_guess(attrs = {})
    return person unless person.nil?
    
    puts "Creating new Person record." if @debug
    Person.create(attrs)
  end
  
  def self.find_by_best_guess(attrs = {})
    return nil if attrs.empty?
    if !attrs[:email].blank?
      puts "Email provided; searching for results." if @debug
      email_results = Person.find_all_by_email_and_type(attrs[:email], nil)
      puts "Found #{email_results.size} email results" if @debug
      if email_results.size == 1
        return email_results.first
      else
        lastname_results = email_results.select{|p| p.lastname == attrs[:lastname] }
        puts "   Found #{lastname_results.size} lastname results" if @debug
        if lastname_results.size == 1
          return lastname_results.first
        elsif lastname_results.size == 0
          puts "   No matching lastnames found" if @debug
        else
          firstname_results = lastname_results.select{|p| p.firstname == attrs[:firstname] }
          puts "      Found #{firstname_results.size} firstname results" if @debug
          if firstname_results.size == 1
            return firstname_results.first
          elsif firstname_results.size == 0
            puts "      No matching firstnames found" if @debug
          else
            puts "Returning most recently updated record." if @debug
            return (firstname_results.sort_by(&:updated_at) rescue firstname_results).last
          end
        end
      end
    else # email was not given, so search for an exact name match and return it only if we find a unique record
      puts "No email provided; searching for exact name match." if @debug
      fullname_results = Person.find_all_by_firstname_and_lastname_and_type(attrs[:firstname], attrs[:lastname], nil)
      puts "   Found #{fullname_results.size} full name results" if @debug
      return fullname_results.first if fullname_results.size == 1
    end
    puts "Could not find any matching records to return." if @debug
    return nil
  end
  
  # returns if the student attended a pipeline orientation
  # if they have not it looks to see if they have since the last time they checked and update their orientation time
  def attended_pipeline_orientation?
    if pipeline_orientation.nil?
      t = event_invites.find(:first, :include=>{:event_time=>{:event=>[:event_type,:unit]}},
                             :conditions=>{:events=>{:event_types=>{:title=>"Orientation"},
                                           :units=>{:abbreviation=>"pipeline"}}},
                             :order=>"checkin_time DESC")
                             
      self.update_attribute(:pipeline_orientation, t.checkin_time) unless t.nil?
    end
    return !pipeline_orientation.nil?
  end
  
  # returns if they have been to an orientation in the past 2 years and
  # if they have had a background check
  def show_pipeline_position_contact?
    if attended_pipeline_orientation? == true && pipeline_background_check.nil? == false
      return (pipeline_background_check >= Time.now-PIPELINE_ORIENTATION_EXPIRATION && pipeline_orientation >= Time.now-PIPELINE_ORIENTATION_EXPIRATION)
    end
    return false
  end
  
  # returns if a person's pipeline orientation is still valid
  def pipeline_orientation_valid?
    if attended_pipeline_orientation? == true
      return (pipeline_orientation >= Time.now-PIPELINE_ORIENTATION_EXPIRATION)
    end
    return false
  end
  
  # returns the Pipeline stop bugging url for the person
  def pipeline_email_stop
    if pipeline_token.nil?
      self.pipeline_token = Token.create
    end
    pipeline_stop_email_url(:host => CONSTANTS[:base_url_host], :student_id => id, :token => pipeline_token.token)
  end   
  
  # Returns true if this person has a +equipment_reservation_restriction_until+ date set in the future
  def equipment_reservation_restriction?
    equipment_reservation_restriction_until && equipment_reservation_restriction_until > Time.now
  end

  # Returns true if this person has a +equipment_reservation_non_student_override_until+ date set in the future.
  # Note: This method will always return +false+ if +equipment_reservation_restriction?+ returns true.
  def valid_equipment_reservation_override?
    return false if equipment_reservation_restriction?
    equipment_reservation_non_student_override_until && equipment_reservation_non_student_override_until > Time.now
  end

end

