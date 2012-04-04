# A student_2 record is created when an offer of admission is made and contains additional student level information about that admitted student. (It makes some sense to think of student_2 as "student-level information that becomes more relevant once an applicant is admitted".) The student_2 record was originally created so the student_1 record was not too "wide" for the systems running at that time. Information in student_2 usually does not get updated via the registration record. The student_2 record does not go away even if the student does not come although application data is purged the 4th Friday (6th Friday sumer qtr) of each quarter. One of the basic elements of Student_2 is that is supposed to be non time dependent data. -- For reasons related to record width limitations in informix, student_2 has been split into component tables student_2a and student_2b. Student_2b contains the \\student_2\"deg_thesis_#" fields. Student_2a contains the remaining student_2 fields. 
class StudentRecord2 < StudentInfo
  set_table_name "student_2"
  set_primary_key "system_key"
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  belongs_to :high_school_foreign_language, :class_name => "Language", :foreign_key => "hs_for_lang_type"
  
end
