# The StudentRecord entity (UWSDB.student_1_v) contains attributes of the student (person) pursuing an officially recognized course of learning at the University of Washington. Student_1 displays the SDB's most current information on a student. The student_1 entity is SDB's closest approximation of a "person." [Unified Definition of Student here, 2001] -- Anyone with a system_key-bearing record in SDB has a student_1 record.
class StudentRecord < StudentInfo
  set_table_name "student_1_v"
  set_primary_key "system_key"
  has_one :student_person, :class_name => "Student", :foreign_key => "system_key"
  has_one :record2, :class_name => "StudentRecord2", :foreign_key => "system_key"
  has_one :address, :class_name => "StudentAddress", :foreign_key => "system_key"
  has_many :transcripts, :class_name => "StudentTranscript", :foreign_key => "system_key"
  has_many :admission_applications, :class_name => "StudentAdmissionApplication", :foreign_key => "system_key"
  has_many :transfers, :class_name => "StudentTransfer", :foreign_key => "system_key"
  has_many :degrees, :class_name => "StudentDegree", :foreign_key => "system_key" do
    def granted
      find :all, :conditions => 'deg_status = 9'
    end
    def applied
      find :all, :conditions => 'deg_status = 3 OR deg_status = 4 OR deg_status = 5'
    end
  end
  has_many :majors, :class_name => "StudentMajor", :foreign_key => "system_key"
  has_many :minors, :class_name => "StudentMinor", :foreign_key => "system_key"
  belongs_to :class_standing_record, :class_name => "ClassStanding", :foreign_key => "class"
  belongs_to :ethnic_ethnicity, :class_name => "Ethnicity", :foreign_key => "ethnic_code"
  belongs_to :hispanic_ethnicity, :class_name => "Ethnicity", :foreign_key => "hispanic_code"
  belongs_to :special_program, :class_name => "SpecialProgram", :foreign_key => "spcl_program"
  belongs_to :high_school, :class_name => "HighSchool", :foreign_key => "high_sch_ceeb_cd"
  belongs_to :last_institution, :class_name => "Institution", :foreign_key => "last_sch_code"
  has_many :registrations, :class_name => "StudentRegistration", :foreign_key => "system_key" do
    def for(qtr)
      return nil unless qtr.is_a? Quarter
      find(:first, :conditions => ['regis_yr = ? and regis_qtr = ?', qtr.year, qtr.quarter_code_id])
    end
    def enrolled
      #find(:all, :conditions => "(request_status = 'A' OR request_status = 'C' OR request_status = 'R')")
      find(:all, :conditions => "enroll_status = 12") # see enrollment status codes: http://depts.washington.edu/reptreq/sdb-code-manual-registration-codes/#enrollmentstatus
    end
  end
  
  PLACEHOLDER_CODES = %w(fullname formal_fullname firstname lastname his_her him_her he_she email salutation formal_greeting
                          class_standing_description majors_list minors_list institution_name last_institution_name transfer_student?
                          student_no student_no_pretty system_key gpa age birth_date gender)
  PLACEHOLDER_ASSOCIATIONS = %w(special_program ethnicity)

  # Returns the Student object that is associated with this StudentRecord. If a Student object does not exist for this student yet, it
  # will automatically be created unless +false+ is passed as the only variable.
  def student(create_person = true)
    return student_person if student_person
    if create_person
       s = Student.find_or_create_by_system_key(system_key)
     else
       nil
     end
  end

  alias :person :student

  def sws
    @sws ||= StudentResource.find_by_system_key(system_key, true)
  end

  # Fetches the regID for this student from the SWS
  def reg_id
    @reg_id ||= StudentResource.find_by_system_key(system_key, false)
  end
  
  # Returns true if we are successfully able to find a matching student record for the given UW NetID. It's still possible that
  # the NetID in question could exist, but it doesn't belong to a student with a student record.
  def self.valid_uw_netid?(netid)
    !find(:first, :conditions => { :uw_netid => netid }).nil?
  end

  def fullname
    student_name_lowc.strip.gsub(',', ', ')
  end

  def lastname
    fullname.split(',')[0]
  end
  
  def firstname
    fullname.split(',')[1].split(' ')[0]
  end
  
  def title
    fullname
  end
  
  def student_no_pretty
    read_attribute('student_no').to_s.rjust(7,'0')
  end
  
  def last_institution_name
    last_institution.try(:name)
  end
  
  def high_school_name
    high_school.try(:name)
  end

  def gender
    s1_gender
  end
  
  # Tries to find a student by name. If the search string includes a comma, then we assume that we're searching last name first
  # and construct a query accordingly. If there is no comma in the search string, then we split the search string into its space-
  # separated parts and construct a condition string in the form of "student_name LIKE '%part_one%' AND student_name LIKE '%part_two%'".
  # Specify a +limit+ to limit the query (default is 10000).
  def self.find_by_name(name, limit = 10000, include_student_person = true, require_valid_student_no = true)
    valid_student_no_condition = "AND student_no != 0" if require_valid_student_no
    name = name.gsub(", ", ",")
    if name.include?(",")
      name_conditions = ["student_name LIKE ? #{valid_student_no_condition}", name + "%"]
    else
      name_parts = name.split
      condition_query = Array.new(name_parts.size, "student_name LIKE ? #{valid_student_no_condition}").join(" AND ")
      condition_values = name_parts.collect{|p| "%" + p + "%"}
      name_conditions = [condition_query, condition_values].flatten
    end
    my_include = include_student_person ? :student_person : nil
    find(:all, :conditions => name_conditions, :limit => limit, :include => my_include)
  end
  
  # Tries to find a student based on the parameter passed. If the parameter is numeric, we search by student number. Otherwise, search
  # by UW NetID and then name. If student number is 0, then return empty array. The reason is that there are some students whose student number is 0 from SDB. 
  # They are still findable by name search
  # Returns an array of the results (or an empty array if nothing is found). This is very similar to Student#find_by_anything, 
  # except for that it returns an array of StudentRecord objects, not Student objects.
  def self.find_by_anything(q, limit = 100)
    students = []
    if q.to_s.is_numeric?
      q.to_i == 0 ? students = [] : students = self.find_by_student_no("#{q}")
    else
      students << self.find_by_uw_netid("#{q}") << self.find_by_name("#{q}", limit)
    end
    return [students] if students.is_a?(StudentRecord)
    return [] if students.nil?
    students.flatten.compact.uniq || []
  end
  
  
  # Since +class+ is a reserved word, that column does not automatically become an instance method. This method creates an easy
  # way to reference the +class+ attribute without causing all sorts of hell with ActiveRecord.
  # 
  # If a Quarter object is passed, this method examines the student's transcript to determine the class_standing of the
  # student during that quarter rather than the current class code stored in student_1_v. Returns nil if the student was
  # not a registered student for that quarter, unless the quarter is a summer quarter -- we'll reference Spring quarter in
  # that case).
  def class_standing(quarter = nil)
    if quarter
      t = transcripts.find(system_key, quarter.year, quarter.quarter_code_id) rescue nil
      t = (transcripts.find(system_key, quarter.prev.year, quarter.prev.quarter_code_id) rescue nil) if t.nil?
      t.nil? ? nil : t.class_standing
    else
      read_attribute(:class)
    end
  end

  # Returns true if this student has a valid transcript record with an undergraduate class code for the given quarter.
  # By default, valid class codes are 1,2,3,4 or 5, but you can override this by passing an array of valid class codes.
  def undergrad_during_quarter?(quarter = Quarter.current_quarter, valid_class_codes = [1,2,3,4,5])
    raise Exception.new("quarter cannot be nil") if quarter.nil?
    valid_class_codes.include? class_standing(quarter)
  end
  
  # In the SDB, "class standing" refers to the most recent class standing for this student. If they are a recent graduate, for instance,
  # this will still return "Senior." To remedy this, we check to see if this student has any valid degrees AND they have a class standing
  # of "4" (senior) and return "Graduated <Quarter>" if so. Otherwise, return the class standing description from the ClassStanding table.
  # 
  # == Options
  # 
  # * +show_upcoming_graduation+: Set to true to also include "(Graduating <Quarter>)" if the student 
  #   has applied for graduation.
  # * +recent_graduate_placeholder+: Return a different text if this is a recent graduate. Default is "Graduated <quarter>"
  # * +reference_quarter+: Base the results of this method on a different quarter instead of the current quarter. This
  #   will examine the student's transcript records instead of using the +class+ standing attribtue from +student_1_v+
  def class_standing_description(options = {})
    ref_class_standing = options[:reference_quarter] ? (class_standing(options[:reference_quarter]) || class_standing) : class_standing
    ref_quarter = options[:reference_quarter] || Quarter.current_quarter
    if !degrees.granted.empty? && degrees.granted.first.quarter < ref_quarter && ref_class_standing == 4
      return options[:recent_graduate_placeholder] if options[:recent_graduate_placeholder]
      return "Graduated #{degrees.granted.first.quarter.title}"
    end
    if !degrees.applied.empty? && ref_class_standing == 4 && options[:show_upcoming_graduation] == true
      return "Senior (Graduating #{degrees.applied.first.quarter.title})"
    end
    ref_class_standing_record = ClassStanding.find(ref_class_standing) rescue nil
    ref_class_standing_record.description unless ref_class_standing_record.nil?
  end

  def institution_name
    CONSTANTS[:university_name]
  end
  
  def email
    return "" if uw_netid.blank?
    address.e_mail_ucs.blank? ? "#{uw_netid.strip}@u.washington.edu" : address.e_mail_ucs.strip rescue "#{uw_netid.strip}@u.washington.edu"
  end

  # Returns the student's GPA as a string of a number to 2 decimal places, e.g., "3.34". Any problems return "unknown".
  def gpa
    '%.2f' % raw_gpa rescue "unknown"
  end
  
  # Returns the student's GPA as a Float value. Any problems return +NaN+.
  def raw_gpa
    tot_grade_points/tot_graded_attmp rescue 0.0/0.0
  end
  
  # Returns the student's GPA for a specific quarter -- NOT the cumulative GPA for that quarter.
  def quarter_gpa(quarter = nil)
    t = transcripts.find(system_key, quarter.year, quarter.quarter_code_id) rescue nil
    raw_gpa = t.nil? ? nil : (t.qtr_grade_points/t.qtr_graded_attmp) rescue nil
    '%.2f' % raw_gpa rescue "unknown"    
  end
  
  # Returns the student's age in years
  def age
    # ((Date.today - birth_date.to_date).to_f/365.25).floor
    age = Date.today.year - birth_date.to_date.year
    age -= 1 if Date.today < birth_date.to_date + age.years #for days before birthday
    return age
  end

  # Returns this student's date of birth. In the SDB, birth date is stored both in a timestamp field (+birth_dt+) and in 3 smallint fields
  # (+yr_of_birth+, +mth_of_birth+, and +day_of_birth+). Sometimes, the birth_dt field is nil or "0000-00-00 00:00:00", in which case this
  # method constructs a valid birth date from these three fields. Otherwise, return +birth_dt+.
  def birth_date
    year = yr_of_birth > 30 ? yr_of_birth+1900 : yr_of_birth+2000
    birth_dt.nil? ? Date.new(year, mth_of_birth, day_of_birth) : birth_dt.to_date
  end
  
  # Finds this records first StudentAdmissionApplication record and returns the value of +#transfer_applicant?+. If an application 
  # record can't be found (not all student records have admission applications), this method returns +nil+.
  def transfer_student?
    return nil if admission_applications.empty?
    admission_applications.first.transfer_applicant?
  end
  
  # Returns a list of the student's majors. By default, this is a comma-separated list of the major abbreviations, but this can
  # be changed by passing parameters to include your own join string and/or include full major names. Does not include
  # the "Non Matriculated" major name.
  # 
  # To see this student's majors list from a previous quarter, specify that quarter for +reference_quarter+. If the student had no
  # majors in that quarter, this method returns a blank string.
  def majors_list(show_full_names = false, join_string = ", ", reference_quarter = nil)
    if reference_quarter.nil?
      ref_majors = majors
    else
      t = transcripts.find(system_key, reference_quarter.year, reference_quarter.quarter_code_id) rescue nil
      t = (transcripts.find(system_key, reference_quarter.prev.year, reference_quarter.prev.quarter_code_id) rescue nil) if t.nil?
      ref_majors = t.nil? ? [] : t.majors
    end
    ref_majors.collect { |m| show_full_names ? m.full_name : m.major_abbr.strip }.reject{|m| m == "Non Matriculated" }.join(join_string)
  end

  # Returns a list of the student's minors. By default, this is a comma-separated list of the minor abbreviations, but this can
  # be changed by passing parameters to include your own join string and/or include full minor names.
  # CURRENTLY, this will always only show abbreviations because titles aren't in the student database.
  def minors_list(show_full_names = false, join_string = ", ")
    minors.collect { |m| m.minor_abbr.strip }.join(join_string)
  end

  # Default ethnic_code for a Student with a "0" ethnic code (this is a very rare situation).
  DEFAULT_ETHNIC_CODE = 987
  
  # The Student database tracks ethnicity in two ways: ethnic_code and hispanic_code. Interestingly, these two codes both
  # refer to the same code table (system_table_21). To reduce the complexity of this arrangement, we look at hispanic_code first
  # and see if the person is hispanic. If so, we return that Ethnicity record. If not, we return the Ethnicity record linked to the
  # ethnic_code attribute. (This might need to be revisited to ensure accuracy)
  def ethnicity
    hispanic_ethnicity.try(:description) == "HISPANIC" ? hispanic_ethnicity : (ethnic_ethnicity || Ethnicity.find(DEFAULT_ETHNIC_CODE))
  end

  # Returns true if this student's resident code is 1 ("RESIDENT") and 2 ("RESIDENT IMMIGRANT") see more: http://depts.washington.edu/reptreq/RptWS-ResidentTable.htm.
  def washington_state_resident?
    resident == 1 || resident == 2
  end

  # Determines what class, if any, the student is to be in class at a given time (or time range, if +end_time+ is supplied) by looking 
  # at the student's registered courses for the quarter and using the #meets_at? method. Returns the StudentRegistrationCourse objects
  # of the courses that meets at that time.
  def in_what_class_at?(start_time, end_time = nil)
    quarter = Quarter.find_by_date(start_time)
    return false if quarter.nil?
    regs = registrations.for(quarter)
    return [] if regs.nil?
    regs.courses.enrolled.select{|c| c.meets_at?(start_time, end_time)}
  end

  # A convenience method that returns a boolean for whether #in_what_class_at? returns any values.
  def in_class_at?(start_time, end_time = nil)
    classes = in_what_class_at?(start_time, end_time)
    return false unless classes
    !classes.empty?
  end
  
end
