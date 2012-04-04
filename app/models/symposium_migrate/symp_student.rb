class SympStudent < SympMigrate
	set_table_name "tblStudent"
	
	set_primary_key "StudentID"
	
	belongs_to :symp_group, :class_name => "SympGroup", :foreign_key => "GroupID"
	
	belongs_to :symp_university, :class_name => "SympUniversity", :foreign_key => "UniversityID"
	
end