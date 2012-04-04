class SympGroup < SympMigrate
	set_table_name "tblGroup"
	
	set_primary_key "GroupID"
	
	has_many :symp_student, :class_name => "SympStudent", :foreign_key => "GroupID"
	
	has_many :symp_mentor, :class_name => "SympMentor", :foreign_key => "GroupID"
	
	belongs_to :symp_session, :class_name => "SympSession", :foreign_key => "SessionID"
	
	belongs_to :symp_assigned_session, :class_name => "SympAssignedSession", :foreign_key => "AssignedSessionID"
	
end