# Registration is the prospective view of the interaction between the student and the University of Washington's course offerings. Registration is the entity of record until Grade Posting/Transcript Generation (process JSR405), at which time the entity of record becomes the transcript (a retrospective view). Note that this implies that the validity of data in Registration ends at this time. Registration is current and future quarter student enrollment information and student program information. For information on prior quarters, refer instead to the transcript tables.
class StudentRegistration < StudentInfo
  set_table_name "registration"
  set_primary_keys :system_key, :regis_yr, :regis_qtr
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  has_many :courses, :class_name => "StudentRegistrationCourse", :foreign_key => ["system_key", "regis_yr", "regis_qtr"] do
    def enrolled
      find(:all, :conditions => "request_status IN ('A','C','R')")
    end
    def fetch_course_credits(course)
      find(:first, :conditions => ['course_branch = ? and crs_number = ? and crs_curric_abbr = ? and crs_section_id = ?', course.course_branch, course.course_no, course.dept_abbrev.strip, course.section_id.strip]).credits.to_i
    end
  end
  
end
