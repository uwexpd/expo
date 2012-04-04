# Curriculum Codes.
# Note that when looking up classes, this is what we use as the key for the first part of a course code (e.g., the "AES" in "AES 150 A").
class Curriculum < StudentInfo
  set_table_name "sr_curric_code"
  set_primary_keys :curric_branch, :curric_last_yr, :curric_last_qtr, :curric_abbr
  
  belongs_to :department, :class_name => "Department", :foreign_key => "curric_dept"
    
  # Returns curriculum codes that are currently valid (i.e., curric_last_yr > quarter.year). Accepts a Quarter object as a parameter.
  named_scope :valid_for, lambda  { |quarter| {:conditions => ['(curric_last_yr >= ? OR (curric_last_yr = ? AND curric_last_qtr >= ?)) AND 
                                                              (curric_first_yr <= ? OR (curric_first_yr = ? AND curric_first_qtr <= ?))', 
                                                              quarter.year, quarter.year, quarter.quarter_code_id, 
                                                              quarter.year, quarter.year, quarter.quarter_code_id] } }

  default_scope :order => 'curric_abbr ASC'

  # Returns the Courses that are valid for the specified Quarter.
  def courses(quarter = Quarter.current_quarter)
    Course.find_all_by_ts_year_and_ts_quarter_and_course_branch_and_dept_abbrev(quarter.year, quarter.quarter_code_id, curric_branch, curric_abbr)
  end
  
  # Returns the course numbers that are valid for the specified Quarter. This is useful for creating a dropdown that includes only
  # the course numbers for this curriculum. This method only returns each course number once, so if a course has 12 sections listed,
  # the course number is still only returned once. Use +section_ids+ to retrieve the different sections for the course found with this
  # method.
  def course_numbers(quarter = Quarter.current_quarter)
    courses(quarter).collect{|c| c.course_no}.uniq.compact.sort
  end
  
  # Returns the section_id's that exist in the time schedule for the specified course_number and Quarter.
  def section_ids(course_number, quarter = Quarter.current_quarter)
    courses(quarter).reject{|c| c.course_no != course_number}.collect{|c| c.section_id.strip}.compact.uniq.sort
  end
  
  def full_name
    curric_full_nm.strip.titleize
  end
  
  def curric_abbr_stripped
    curric_abbr.strip
  end
  
end
