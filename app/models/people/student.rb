# Models a student in the context of EXPo.  Student records are associated with student_1_v records in the UWSDB.
# 
# Note that actual student information is stored in the studentdb models, which connect to UWSDB.  This guarantees that student information is as up-to-date as possible, because we can automatically retrieve student data on a regular basis.  Student models _only_ exist for students that are in the EXPo database, not for every student in the student database.  This is why methods like +find_or_create_by_student_no+ exist to allow an EXPo Student record to be created any time we reference a student.
class Student < Person
  belongs_to :sdb, :class_name => "StudentRecord", :foreign_key => "system_key"
  validates_presence_of :student_no

  has_many :appointments, :foreign_key => "student_id" do
    def today; find(:all, :conditions => "DATE(start_time) = '#{Time.now.to_date}'"); end
  end

  attr_accessor :electronic_signature
  
  delegate :class_standing_description, :raw_gpa, :gpa, :institution_name, :majors_list, :minors_list, :minors, :majors, :age, :transfer_student?, :washington_state_resident?, :to => :sdb

  # For use in polymporphic finds. TODO: This is a hack.
  def self.parent_class
    Person
  end

  PLACEHOLDER_CODES = %w(fullname formal_fullname firstname lastname his_her him_her he_she email salutation formal_greeting
                          class_standing_description majors_list minors_list institution_name awards_list pipeline_email_stop
                          student_no system_key transfer_student?)

  SDB_CACHE_VALIDITY_LENGTH = {
    :name     => 1.month,
    :class_standing     => 1.month,
    :gender     => 1.year,
    :email    => 1.week
  }
  
  # Checks if the SDB-based contact information for this record is out-of-date by comparing the current +sdb_update_at+
  # with the constants SDB_CACHE_VALIDITY_LENGTH. This method is called during any methods that pull student name or 
  # email information.
  def sdb_update(attr_group)
    valid_length = SDB_CACHE_VALIDITY_LENGTH[attr_group]
    self.fetch_sdb_updates if valid_length.nil? || sdb_update_at.nil? || Time.now - sdb_update_at > valid_length
  end
  
  # Fetches the requested attribute group from the SDB data store and saves it into our local cache, then updates this record's
  # +sdb_update_at+ attribute. Allowed attribute groups are :name and :email.
  def fetch_sdb_updates
    log_with_color "UWSDB Fetch", "Fetching student data update for Student #{self.id}"
    return false if sdb.nil?
    attrs = { 
      :fullname => sws ? sws.fullname : sdb.fullname,
      :firstname => sws ? sws.firstname : sdb.firstname,
      :lastname => sws ? sws.lastname : sdb.lastname,
      :email => sdb.email,
	    :gender => sdb.s1_gender,
	    :class_standing_id => sdb.class_standing,
      :sdb_update_at => Time.now 
    }
    update_attributes!(attrs)
  end
  
  def sws
    @sws ||= StudentResource.find_by_system_key(system_key, true)
  end

  # Fetches the regID for this student, from the database if we have it locally, or from SWS if we haven't fetched it yet.
  def reg_id
    if read_attribute(:reg_id).blank?
      @reg_id ||= StudentResource.find_by_system_key(system_key, false)
      update_attribute(:reg_id, @reg_id)
    else
      @reg_id ||= read_attribute(:reg_id)
    end
    @reg_id
  end
  
  def firstname
    # nickname.blank? ? sdb.firstname : nickname
    self.sdb_update(:name)
    nickname.blank? ? read_attribute(:firstname) : nickname
  end
  
  
  def formal_firstname(include_nickname = false)
    # sdb.firstname
    self.sdb_update(:name)
    include_nickname ? "#{read_attribute(:firstname)}#{" (" + nickname + ")" unless nickname.blank?}" : read_attribute(:firstname)
  end
  
  def lastname
    # sdb.lastname
    self.sdb_update(:name)
    read_attribute(:lastname)
  end
  
  def fullname
    # nickname.blank? ? sdb.fullname : sdb.fullname + " (#{nickname})" rescue "(no student record found)"
    self.sdb_update(:name)
    nickname.blank? ? read_attribute(:fullname) : read_attribute(:fullname) + " (#{nickname})" rescue "(no student record found)"
  end
  
  def gender
	self.sdb_update(:gender)
    read_attribute(:gender)
  end
  
  def email
    # sdb.email
    self.sdb_update(:email)
    read_attribute(:email)
  end
  
  def student_no
    sdb.nil? ? read_attribute('student_no').to_s.rjust(7,'0') : sdb.student_no.to_s.rjust(7,'0')
  end
  
  def current_credits(quarter = Quarter.current_quarter)
    return 0 if sdb.registrations.size < 1
    sr = sdb.registrations.find_by_regis_yr_and_regis_qtr(quarter.year, quarter.quarter_code_id)
    sr.nil? ? 0 : sr.current_credits
  end
  
  def full_time?(quarter = Quarter.current_quarter)
    current_credits(quarter) >= CONSTANTS[:credits_required_for_full_time]
  end

  # Returns true if this student is an undergraduate at the University. A student is considered undergraduate if his or her
  # +class_standing+ is <= 5.
  def undergrad?
    sdb.class_standing <= 5
  end
  
  def class_standing_id
	self.sdb_update(:class_standing)
	read_attribute(:class_standing_id)
  end

  # Returns this student's list of majors from the SDB
  # def majors_list(show_full_names = false, join_string = ", ")
  #   sdb.major_list(show_full_names, join_string)
  # end
  

  # Checks if this student has a valid service-learning risk waiver on file. The valid lifetime is defined in the
  # +service_learning_risk_lifetime+ EXPo constant.
  def valid_service_learning_waiver_on_file?
    return false if service_learning_risk_paper_date.nil?
    return false if Time.now - service_learning_risk_paper_date < 0 # in the future
    return false if Time.now - service_learning_risk_paper_date > ((eval(CONSTANTS[:service_learning_risk_lifetime]) rescue nil) || 3.months)
    true
  end

  # Checks if this student has a valid service learning risk waiver at all, either on paper or digitally. If the student is under
  # age 18, they must have a valid paper waiver on file. If not, check if the +service_learning_risk_date+ is within the lifetime
  # for service-learning risk waivers as defined by the +service_learning_risk_lifetime+ EXPo constant.
  def valid_service_learning_waiver?
    valid_lifetime = ((eval(CONSTANTS[:service_learning_risk_lifetime]) rescue nil) || 3.months)
    return valid_service_learning_waiver_on_file? if sdb.age < 18
    return false if service_learning_risk_date.nil? and service_learning_risk_paper_date.nil?
    unless service_learning_risk_date.nil?
      return true if Time.now - service_learning_risk_date < valid_lifetime
    end
    unless service_learning_risk_paper_date.nil?
      return true if Time.now - service_learning_risk_paper_date < valid_lifetime
    end
    false
  end

  # Checks to see if this Student is enrolled in the specified Course.
  def enrolled_in?(course)
    course.all_enrollees.include?(self)
  end
  
  # Given an array of Courses, removes the Courses for which this Student is not enrolled
  def enrolled_in_which?(courses)
    courses.reject {|course| !self.enrolled_in?(course)}
  end
    
  # Returns an array of the Courses that this student is enrolled in for the given quarter. 
  # (Returns actual Course objects, not StudentRegsitrationCourse records)
  # To include courses where this student is force-enrolled as a CourseExtraEnrollee, specify
  # :include_extra_enrollees option as true.
  def enrolled_courses(quarter = Quarter.current_quarter, options = {})
    @registrations ||= {}; @enrolled_courses ||= {}
    @registrations[quarter] ||= sdb.registrations.for(quarter)
    if @registrations[quarter].nil? && !options[:include_extra_enrollees]
      return [] 
    elsif !@registrations[quarter].nil?
      # @enrolled_courses ||= r.courses.enrolled.collect(&:course)
      @enrolled_courses[quarter] ||= @registrations[quarter].courses.find(:all, 
                                                  :conditions => "request_status IN ('A','C','R')", 
                                                  :include => :course).collect(&:course)
    end
    if options[:include_extra_enrollees]
      
      if @enrolled_courses[quarter] && options[:remove_old_extra_enrollees]
        for cee in course_extra_enrollees.for(quarter)
          if @enrolled_courses[quarter].include?(cee.course)
            cee.destroy
          end
        end
      end
      
      course = course_extra_enrollees.for(quarter).collect(&:course)
      if @enrolled_courses[quarter]
        @enrolled_courses[quarter] << course
      else
        @enrolled_courses[quarter] = course
      end
      @enrolled_courses[quarter] = @enrolled_courses[quarter].flatten.uniq
    end
    @enrolled_courses[quarter]
  end
    
  # Returns an array of which ServiceLearningCourses a Student is enrolled in for the specified Quarter. If left blank,
  # this defaults to the current quarter. Pass an array of Quarters to do the lookup for each of those quarters.
  def enrolled_service_learning_courses(quarter = Quarter.current_quarter, unit = Unit.find_by_abbreviation("carlson"), options = {:enrolled_courses_options => {}})
    quarter = [quarter] unless quarter.is_a?(Array)
    @enrolled_service_learning_courses = []
    for q in quarter
      service_learning_courses = unit.nil? ? q.service_learning_courses : q.service_learning_courses.for_unit(unit)
      enrolled_courses = enrolled_courses(q, {:include_extra_enrollees => true}.merge(options[:enrolled_courses_options]))
      eslc ||= extra_service_learning_courses
      for slc in service_learning_courses
        @enrolled_service_learning_courses << slc if !(slc.courses.collect(&:course) & enrolled_courses).empty? || eslc.include?(slc)
      end
    end
    @enrolled_service_learning_courses.uniq
    # service_learning_courses = quarter.is_a?(Array) ? quarter.collect(&:service_learning_courses).flatten : quarter.service_learning_courses
    # service_learning_courses.reject {|service_learning_course| !service_learning_course.enrolls?(self, :include_extra_enrollees => true)}
  end

  # Tries to find a student based on the parameter passed. If the parameter is numeric, we search by student number. Otherwise, search
  # by UW NetID and then name. Returns an array of the results (or an empty array if nothing is found).
  # 
  # Note: In previous versions, this returned nil when no results were found, instead of an empty array. Changing this may cause problems
  # elsewhere, such as in Admin::StudentsController and ExtraEnrolleesController.
  def self.find_by_anything(q, limit = 10000)
    students = []
    if q.to_s.is_numeric?
      q.to_i == 0 ? students = [] : students = Student.find_by_student_no("#{q}")      
    else
      students << Student.find_by_uw_netid("#{q}") << Student.find_by_name("#{q}", limit)
    end
    return [students] if students.is_a?(Student)
    return [] if students.nil?
    students.flatten.compact.uniq || []
  end
    
  # @alias for find_or_create_by_student_no
  def self.find_by_student_no(student_no)
    find_or_create_by_student_no(student_no)
  end
    
  # Find a student by student number and also create a Student record for that student if needed.
  # - Returns a Student object or nil if search fails
  def self.find_or_create_by_student_no(student_no)
    # sr = StudentRecord.find_by_student_no(student_no)
    # if sr.blank?
    #   nil
    # else
    #   s = Student.find_by_system_key(sr.system_key)
    #   if s.blank?
    #     s = Student.find(:first, :conditions => { :student_no => student_no })
    #     if s.blank?
    #       Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
    #     else
    #       s.system_key = sr.system_key; s.save; s
    #     end
    #   else
    #     s
    #   end
    # end
    sr = StudentRecord.find_by_student_no(student_no)
    return nil if sr.blank?
    s = Student.find_by_system_key(sr.system_key)
    if s.blank?
      Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
    else
      s
    end
  end
  
  # @alias for find_or_create_by_uw_netid
  def self.find_by_uw_netid(uw_netid)
    find_or_create_by_uw_netid(uw_netid)
  end
  
  # Find a student by uw_netid and also create a Student record for that student if needed.
  # - Returns a Student object or nil if search fails
  def self.find_or_create_by_uw_netid(uw_netid)
    # INFO I changed this so that we don't rely on student_no in the lookup. mharris2 4/13/10
    # sr = StudentRecord.find_by_uw_netid(uw_netid)
    # if sr.blank?
    #   nil
    # else
    #   s = Student.find_by_system_key(sr.system_key)
    #   if s.blank?
    #     s = Student.find(:first, :conditions => { :student_no => sr.student_no })
    #     if s.blank?
    #       Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
    #     else
    #       s.system_key = sr.system_key; s.save; s
    #     end
    #   else
    #     s
    #   end
    # end
    sr = StudentRecord.find_by_uw_netid(uw_netid)
    return nil if sr.blank?
    s = Student.find_by_system_key(sr.system_key)
    if s.blank?
      Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
    else
      s
    end
  end
  
  # Find a student by name. This will create a record for every student found in the people table.
  def self.find_by_name(name, limit = 10000)
    sr = StudentRecord.find_by_name(name, limit)
    students = []
    if sr.blank?
      nil
    else
      # sr.each do |s|
      #   students << self.find_or_create_by_student_no(s.student_no)
      # end
      # students
      sr.collect(&:student).flatten
    end
  end
  
  # Returns true if the SDB contact info update has happened since the requested time +t+. 
  # Overrides Person#contact_info_updated_since.
  def contact_info_updated_since(t)
    return false if sdb_update_at.nil?
    t < sdb_update_at
  end
  
  protected
  
  def log_with_color(message, detail, message_color = "4;33;1")
    logger.debug { "  \e[#{message_color}m#{message}\e[0m   #{detail}" }
  end
  
end
