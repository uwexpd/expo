# The student_1_minor entity displays a student's chosen secondary ("minor") course(s) through the University (college, minor, pathway). (Compare student_1_college.)
class StudentMinor < StudentInfo
  set_table_name "student_1_minor_group"
  set_primary_keys :system_key, :index1, :minor_number
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  
  # # Returns the Major object associated with this StudentMajor. We don't use a true association here because of the inconsistincies
  # # of the data structures of the SDB.
  # def major
  #   Major.find( :first, 
  #               :conditions => ["major_branch = ? AND major_pathway = ? AND major_abbr = ?", branch, pathway, major_abbr],
  #               :order => "major_last_yr DESC, major_last_qtr DESC")
  # end
  # 
  # # Returns the full name of the major, stripped of whitespace.
  # def full_name
  #   major.major_full_nm.strip rescue major_abbr
  # end
  
end
