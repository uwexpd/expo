# Models a course identified in the Student DB Time Schedule.
# 
# The course can have _registrants_ and _extra_enrollees_. Extra enrollees are Students who have been identified by program staff as being enrolled in this Course. This is useful because our copy of the Student DB has a 24-hour delay, so if a student registers for a course and then tries to immediately register for a service learning opportunity (for instance), EXPo will not show them as a registrant.
class Course < StudentInfo
  set_table_name "time_schedule"
  set_primary_keys :ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id
  
  has_many :service_learning_course_courses
  has_many :service_learning_courses, :through => :service_learning_course_courses
  has_many :course_extra_enrollees, :foreign_key => [:ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id]
  has_many :extra_enrollees, :through => :course_extra_enrollees, :source => :person  

  def <=>(o)
    short_title <=> o.short_title
  end

  def quarter
    Quarter.find_easily(ts_quarter, ts_year)
  end

  # Fetches the Department that this Course belongs to. We can't make this a normal association because the student DB doesn't store the
  # Department primary key ("dept_code") in the Time Schedule. (Why not? Nobody knows!)
  def department
    curriculum.department
  end

  # Fetches the Curriculum that this Course belongs to.
  def curriculum
    Curriculum.valid_for(Quarter.find_easily(ts_quarter, ts_year)).find_by_curric_abbr(dept_abbrev)
  end

  # Provides a short title of the class, e.g. AES 150.
  def short_title
    "#{dept_abbrev.to_s.strip} #{course_no.to_s.strip} #{section_id.to_s.strip}"
  end
  
  # Provides the full title of the course in titleized format, e.g. American Ethnic Studies 150.
  def full_title
    "#{curriculum.full_name rescue nil || dept_abbrev.to_s.strip} #{course_no.to_s.strip} #{section_id.to_s.strip}"
  end
  
  def course_title
    read_attribute :course_title
  end
  
  # Tries to parse a string into dept_abbrev, course_no, and section_id
  def self.match(abbrev)
    abbrev.match /^([\w\s]{0,10}?)\s*(\d{3})\s*(\w{0,2})/
  end
  
  # Finds all valid courses that exist for the given dept_abbrev, course_no in the given quarter(s). For instance,
  # use this method to find all "BIOL 499" courses in 2009-2010. This will search through each quarter and return an array
  # of all course sections that are valid in all course branches. Specify an optional section_id option to limit just to
  # that section ID.
  def self.find_all_by_short_title(dept_abbrev, course_no, quarters, extra_conditions = {})
    quarters = [quarters] unless quarters.is_a?(Array)
    extra_conditions.delete :section_id if extra_conditions[:section_id].blank?
    results = []
    for quarter in quarters
      for course_branch in [0,1,2]
        conditions = {  :ts_year => quarter.year, 
                        :ts_quarter => quarter.quarter_code_id, 
                        :dept_abbrev => dept_abbrev.upcase, 
                        :course_no => course_no,
                        :course_branch => course_branch,
                        :delete_flag => '' }.merge(extra_conditions)
        results << find(:all, :conditions => conditions)
      end
    end
    results.flatten.compact.uniq
  end
  
  # Returns an array of StudentRegistrationCourse records who are registered for this Course. We do this by searching through the
  # registration_courses table and find any records that match this course and have a request_status of either A(dd), C(hange) or
  # R(e-register).
  def registrants
    @registrants ||= StudentRegistrationCourse.find(:all, 
                                        :conditions => ["regis_yr = ? AND regis_qtr = ? AND sln = ? AND 
                                                        (request_status = 'A' OR request_status = 'C' OR request_status = 'R')",
                                                        ts_year, ts_quarter, sln],
                                        :include => { :student_record => { 
                                                        :student_person => {
                                                          :service_learning_placements => :evaluation 
                                                          }
                                                        }
                                                      },
                                        :joins => :student_record,
                                        :order => "student_name" )
  end
  
  def registrants_count
    @registrants_count ||= StudentRegistrationCourse.count(:all, 
                                    :conditions => ["regis_yr = ? AND regis_qtr = ? AND sln = ? AND 
                                                    (request_status = 'A' OR request_status = 'C' OR request_status = 'R')",
                                                    ts_year, ts_quarter, sln])
  end
  
  # Returns the full group of Students who are enrolled or registered for this class, both officially in the SDB and unofficially
  # by program staff.
  def all_enrollees
    @all_enrollees ||= (registrants.collect{|r| r.student unless r.student_record.nil? }.flatten + extra_enrollees).uniq
  end
  
  # Returns the count of Students who are enrolled or registered for this class (the same set return by all_enrollees).
  def all_enrollee_count
    @all_enrollee_count = 0
    @all_enrollee_count += registrants_count
    @all_enrollee_count += course_extra_enrollees.count
  end
  
  # Returns true if the Student is enrolled in the course. By default, this includes extra_enrollees, but you can include only
  # officially-enrolled students by specifying +false+ for the :include_extra_enrollees option.
  def enrolls?(student, options = {})
    options = {:include_extra_enrollees => true}.merge(options)
    return true if !StudentRegistrationCourse.find(:all, 
                                        :conditions => ["regis_yr = ? AND regis_qtr = ? AND sln = ? AND system_key = ? AND
                                        (request_status = 'A' OR request_status = 'C' OR request_status = 'R')",
                                        ts_year, ts_quarter, sln, student.system_key]).empty?
    return true if options[:include_extra_enrollees] == true && extra_enrollees.include?(student)
    false
  end

  # Returns true if +ts_research+ is +YES+
  def research_course?
    ts_research?
  end

  # Returns true if +ts_service+ is +YES+
  def service_course?
    ts_service?
  end

  # Returns true if this course has a joint-listed course specified.
  def joint_listed?
    !joint_listed_with.nil?
  end
  
  # Returns true if +delete_flag+ is "+@+"
  def withdrawn?
    delete_flag == "@"
  end

  # Returns the abbreviation of the joint-listed course or nil if the "with_" fields are blank.
  def joint_listed_with
    return nil if with_branch.zero? && with_dept_abbrev.to_s.strip.blank? && with_course_no.zero?
    "#{with_dept_abbrev.to_s.strip} #{with_course_no.to_s.strip} #{with_section_id.to_s.strip}"
  end

  # Returns true if this class meets on Monday
  def monday?;    day_of_week.include?("M");  end
  def tuesday?;   day_of_week.include?("T");  end
  def wednesday?; day_of_week.include?("W");  end
  def thursday?;  day_of_week.include?("R");  end
  def friday?;    day_of_week.include?("F");  end
  def saturday?;  false;                      end
  def sunday?;    false;                      end
  
  # Returns true if this class is in session during the time-of-day specified. You can pass an actual Time object (only
  # the time portion will be used in the comparison) or a string like "1:30 pm" or "13:30" or "1330".
  # Pass a second parameter as an ending_time to evaluate a range of time (optional).
  def meets_at_time?(start_t, end_t = nil)
    start_time = Time.parse(sdb_course_convert_time(starting_time.clone).to_s.insert(-3, ":"))
    end_time = Time.parse(sdb_course_convert_time(ending_time.clone).to_s.insert(-3, ":"))
    if end_t
      user_range = (parse_to_time(start_t).to_i..parse_to_time(end_t).to_i)
      (start_time.to_i..end_time.to_i).step(60) do |m|
        return true if user_range.include?(m)
      end
      false
    else
      (start_time..end_time).include?(parse_to_time(start_t))
    end
  end
  
  # Returns true if this class is scheduled to meet at the DateTime specified. Pass a second parameter as an ending_time to
  # evaluate a range of time (optional).
  def meets_at?(start_time, end_time = nil)
    raise Exception.new("Invalid date object") unless start_time.is_a?(Time) || start_time.is_a?(DateTime)
    return false unless quarter.sdb.include?(start_time) # are we even in the right quarter?
    return false unless instance_eval("#{start_time.strftime("%A").downcase}?")
    meets_at_time?(start_time, end_time)
  end

  private
  
  # Parse an unformatted time into a valid time object. Accepts:
  # 
  # * Ruby Time objects
  # * Strings like "11:30" or "0120"
  # * Numbers like 1020 or 0215
  # 
  # Remember that you need to provide 24-hour times to this method. If you need to convert an SDB-style time to
  # 24-hour time, use #sdb_course_convert_time first.
  def parse_to_time(t)
    if t.is_a?(Time)
      t = Time.parse(t.to_s(:time))
    elsif t.is_a?(String) && t.include?(":")
      t = Time.parse(t)
    elsif t.is_a?(String)
      t = Time.parse(t.insert(-3, ":"))
    elsif t.is_a?(Numeric)
      t = Time.parse(t.to_s.insert(-3, ":"))
    else
      raise Exception.new("Invalid parameter")
    end
  end
  
  # The SDB does not store times as AM or PM, so this method infers as such:
  # * times between 0100 and 0430 are always converted to PM
  # * times between 0430 and 1159 are converted to PM only if +pm_flag+ == "P"
  # * times between 1200 and 1259 are converted to PM
  def sdb_course_convert_time(t)
    t = t.to_i
    if (100..430).include?(t)
      t = t + 1200
    elsif (430..1159).include?(t)
      t = t + 1200 if pm_flag.strip == "P"
    elsif (1200..1259).include?(t)
      t = t + 1200
    end
    t
  end
  
end
