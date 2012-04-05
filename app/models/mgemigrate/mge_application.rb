class MgeApplication < MgeMigrate
	#set_table_name "Application"
	# for the differnces between the two access files
	set_table_name "App_Trim_Inc_ID"
	
	set_primary_key "Application_Key"
	
	belongs_to :mge_student, :class_name => "MgeStudent", :foreign_key => "Student_Key"
	
	has_many :mge_application_mentor, :class_name => "MgeApplicationMentor", :foreign_key => "Application_Key"
	
	has_one :mge_award, :class_name => "MgeAward", :foreign_key => "AWARD_TYPE"
	
	# Gets all of the students applications from the passed student_key
	def self.get_student_applications(student_key)
		MgeApplication.find(:all, :conditions =>{ :Student_Key => student_key})
	end
	
	
end