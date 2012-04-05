# The sr_adm_appl entity contains the current view of the official record of an applicant's request for admission to the university.  Data in this entity is volatile (time-sensitive, subject to change).  The entity does not contain the complete record of the application.  Essays and other important data are kept in paper files in the respective admissions offices.  Note that this entity contains the current view of the application record, not simply a view of the current application.  Note also that it is possible for a student record to exist without a related application record (e.g. EO).	
class StudentAdmissionApplication < StudentInfo
  set_table_name "sr_adm_appl"
  set_primary_keys :system_key, :appl_no, :appl_qtr, :appl_yr
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  
  default_scope :order => "appl_no DESC"
  
  # Returns true if this application is a transfer application. Transfer students have a "2" or "4" value
  # for the +appl_type+ if they came from a 2-year or 4-year school, respectively.
  def transfer_applicant?
    appl_type == "2" || appl_type == "4"
  end
  
end