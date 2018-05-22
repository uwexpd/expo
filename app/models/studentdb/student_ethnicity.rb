class StudentEthnicity < StudentInfo
  set_table_name "student_1_ethnic"
  set_primary_key "system_key"
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  belongs_to :ethnic_ethnicity, :class_name => "Ethnicity", :foreign_key => "ethnic"  
  
end
