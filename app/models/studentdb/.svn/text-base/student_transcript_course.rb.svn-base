# Every course that a student has taken has its own StudentTranscriptCourse records, organized by quarter and assembled under a StudentTranscript object.
class StudentTranscriptCourse < StudentInfo
  set_table_name "transcript_courses_taken"
  set_primary_keys :system_key, :tran_yr, :tran_qtr, :index1
  belongs_to :transcript, :class_name => "StudentTranscript", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  
  # Returns the associated Course object.
  def course
    Course.find [tran_yr, tran_qtr, course_branch, course_number, dept_abbrev, section_id]
  end
  
  # Returns the grade earned in the course, properly formatted. Since the SDB stores grades as strings with no decimals, two digit
  # grades must be converted into a decimal number, but strings such as "CR" for credit/no-credit classes must stay the same
  def grade_formatted
    return "X" if grade.strip.blank?
    return "0.0" if grade == "00"
    return (grade.to_f/10).to_s unless grade.to_f == 0.0
    return grade
  end

end
