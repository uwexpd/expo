# Each institution that a student previously attended (and had transfer credits from) has its own StudentTransfer record. Each one has multiple StudentTransferCourse records displayed on a transcript.
class StudentTransfer < StudentInfo
  set_table_name "sr_transfer"
  set_primary_keys :system_key, :institution_code
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  has_many :courses, :class_name => "StudentTransferCourse", :foreign_key => ["system_key", "institution_code"]
  belongs_to :institution, :class_name => "Institution", :foreign_key => "institution_code"
end