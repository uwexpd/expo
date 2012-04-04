class MgeStudent < MgeMigrate
	#set_table_name "Student"
	# for the differences between the two access files
	set_table_name "Student_Trim_Inc_ID"
	
	set_primary_key "Student_Key"
	
	has_many :applications, :class_name => "MgeApplication", :foreign_key => "Student_Key"
	
	# Gets only the information needed from the Student table
	def self.get_student_migrate_info()
		MgeStudent.find_by_sql "SELECT Student_Key, St_Number, ten_yr_contact, ten_yr_notes, ten_year_attendee FROM Student_Trim_Inc_ID"
	end
	
end