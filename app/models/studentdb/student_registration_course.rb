# registration_pro is the portion of registration that occurs for each of a student's courses. It is a record of all courses that a student has added for a particular quarter. (Occurs clause max is 27.) registration_pro presents one entry per unique registration (sln plus dup_enroll). request_status shows the current status of that unique registration.
class StudentRegistrationCourse < StudentInfo
  set_table_name "registration_courses"
  set_primary_keys :system_key, :regis_yr, :regis_qtr, :index1
  belongs_to :registration, :class_name => "StudentRegistration", :foreign_key => ["system_key", "regis_yr", "regis_qtr"]
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"

  belongs_to :course, :class_name => "Course", 
              :foreign_key => ["regis_yr", "regis_qtr", "course_branch", "crs_number", "crs_curric_abbr", "crs_section_id"]

  delegate :meets_at?, :meets_at_time?, :to => :course

  FAILING_GRADES = %w[ 00 01 02 03 04 05 06 0.1 0.2 0.3 0.4 0.5 0.6 F I NC NS W W3 W4 W5 W6 W7 ]
  
  def student
    # puts "StudentRegistrationCourse.student for #{system_key}"
    if student_record.nil?
      nil
    else
      student_record.student.nil? ? nil : student_record.student
    end
  end
  
  # Returns true if +grade+ matches one of the values in FAILING_GRADES array.
  def failed?
    FAILING_GRADES.include?(grade.strip)
  end
  
  # Returns true if request_status is A, C, or R. A StudentRegistrationCourse record exists for every
  # registration _transaction_, so this can tell you if this should course should be displayed, for instance, in a
  # current quarter schedule.
  def enrolled?
    ['A','C','R'].include?(request_status)
  end
  
  
  
end
