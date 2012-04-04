class CourseTitle < StudentInfo
  set_table_name "sr_course_titles"
  set_primary_keys :department_abbrev, :course_number, :last_eff_yr, :last_eff_qtr, :course_branch
  
  
end
