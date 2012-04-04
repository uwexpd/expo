class SympMentor < SympMigrate
	set_table_name "tblFaculty"
	
	set_primary_key "FacultyID"
	
	belongs_to :symp_group, :class_name => "SympGroup", :foreign_key => "GroupID"
	
	belongs_to :symp_department, :class_name => "SympDepartment", :foreign_key => "DepartmentID"
	
end