# UW_Degree indicates the degrees a student earned or applied for at the University of Washington and attributes concerning the degree. If the number showing in index1 is greater than 1, the student earned more than one degree. The degree information is entered on the SRF335 screen on keynes.
# 
# Details of student_2_uw_degree_info:
# http://data.engr.washington.edu/pls/portal30/WAREHOUSE.RPT_ATTRIBUTE.SHOW?p_arg_names=ent&p_arg_values=student_2_uw_degree_info
class StudentDegree < StudentInfo
  set_table_name "student_2_uw_degree_info"
  set_primary_keys :system_key, :index1
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  
  # The quarter that this degree was granted or applied for.
  def quarter
    Quarter.find_easily(deg_earned_qtr, deg_earned_yr)
  end
  
  # Returns true if deg_status == 9 ("GRANTED"). Otherwise, the student has only applied and not yet earned the degree.
  def granted?
    deg_status == 9
  end
end
