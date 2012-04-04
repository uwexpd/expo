class SympAssignedSession < SympMigrate
	set_table_name "tblSessionInformation"
	
	set_primary_key "AssignedSessionID"
	
	has_many :symp_group, :class_name => "SympGroup", :foreign_key => "AssignedSessionID"
	
end