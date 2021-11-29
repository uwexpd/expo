# The student_1_college entity displays a student's chosen primary ("major") course through the University (college, major, pathway) and the degree to which the student aspires (degree level, degree type). (Compare student_1_minor.)
class StudentMajor < StudentInfo
  set_table_name "student_1_college_major"
  set_primary_keys :system_key, :index1, :major_number
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  
  delegate :discipline_category, :to => :major
  
  # Returns the Major object associated with this StudentMajor. We don't use a true association here because of the inconsistincies
  # of the data structures of the SDB.
  def major
    Major.find( :first, 
                :conditions => ["major_branch = ? AND major_pathway = ? AND major_abbr = ?", branch, pathway, major_abbr],
                :order => "major_last_yr DESC, major_last_qtr DESC")
  end
  
  # Returns the full name of the major, stripped of whitespace.
  def full_name
    major.title.gsub(/\s{2,}/, ' ') rescue major_abbr
  end
  
  def to_s
    full_name
  end

  # Campus code: 0 => Seattle, 1 => Bothell, 2 => Tacoma
   def major_branch_name
     if branch == 0
       "Seattle Campus"
     elsif branch == 1
       "Bothell Campus"
     elsif branch == 2
       "Tacoma Campus"
     else
       "Other Campus"
     end
   end
   
end
