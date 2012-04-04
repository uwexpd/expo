# (No description in UWSDB Data Warehouse.)  Contains one record per quarter that a student completed (or simply enrolled in?) courses at the UW.  Contains information about credits attempted, grade points earned, etc.  A collection of StudentTranscript objects makes up a student's full transcript.  Transcript information is sequential and must be displayed in proper order so that calculations (e.g., cumulative GPA) make sense.
class StudentTranscript < StudentInfo
  set_table_name "transcript"
  set_primary_keys :system_key, :tran_yr, :tran_qtr
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  has_many :courses, :class_name => "StudentTranscriptCourse", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  has_many :majors, :class_name => "StudentTranscriptMajor", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  has_many :minors, :class_name => "StudentTranscriptMinor", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  has_many :independent_studies, :class_name => "StudentTranscriptIndependentStudy", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  belongs_to :scholarship_status, :class_name => "ScholarshipType", :foreign_key => "scholarship_type"
  
  def quarter
    Quarter.find_easily(tran_qtr, tran_yr)
  end
  
  # Since +class+ is a reserved word, that column does not automatically become an instance method. This method creates an easy
  # way to reference the +class+ attribute without causing all sorts of hell with ActiveRecord.
  def class_standing
    read_attribute(:class)
  end
  
end
