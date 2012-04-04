class SympUniversity < SympMigrate


	set_table_name "tblUniversity"
	
	set_primary_key "UniversityID"
	
	has_many :symp_university, :class_name => "SympStudent", :foreign_key => "UniversityID"

	
end