class MgeMentor < MgeMigrate
	#set_table_name "Mentor"
	# for the differnces between the two access files
	set_table_name "Mentor_Additions"
	
	set_primary_key "Mentor_Key"
	
	belongs_to :mge_student, :class_name => "MgeStudent", :foreign_key => "Student_Key"
	
	has_many :mge_application_mentor, :class_name => "MgeApplicationMentor", :foreign_key => "Mentor_Key"
	
	def self.get_mentor(mentor_key)
		MgeMentor.find(:first, :conditions =>{:Mentor_Key => mentor_key})
	end
	
end