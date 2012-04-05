# There's no documentation in the Warehouse for this item. I think it is the title of any independent study courses that a student enrolled in for a specific quarter.
class StudentTranscriptIndependentStudy < StudentInfo
  set_table_name "transcript_ind_stdy_title"
  set_primary_keys :system_key, :tran_yr, :tran_qtr, :index1
  belongs_to :transcript, :class_name => "StudentTranscript", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
end
