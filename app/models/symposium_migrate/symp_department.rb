class SympDepartment < SympMigrate
	set_table_name "tlkpDepartment"
	
	set_primary_key "DepartmentID"
	
	has_many :symp_mentor, :class_name => "SympMentor", :foreign_key => "DepartmentID"
	
end