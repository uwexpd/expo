class OmsfaStudentInfo < ActiveRecord::Base
  set_table_name "omsfa_student_info"
  belongs_to :person
end
