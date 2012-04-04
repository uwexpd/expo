class MgeApplicationMentor < MgeMigrate
	#set_table_name "Application_Mentor"
	# for the differnces between the two access files
	set_table_name "Application_Mentor_Additions"
	
	set_primary_key "Application_Mentor_Key"
	
	belongs_to :mge_application, :class_name => "MgeApplication", :foreign_key => "Application_Key"
	belongs_to :mge_mentor, :class_name => "MgeMentor", :foreign_key => "Mentor_Key"
	belongs_to :mge_application_mentor_status_lookup, :class_name => "MgeApplicationMentorStatusLookup", :foreign_key => "Status_Key"
	
	def self.reviewers_and_mentors_for_application(application_key)
		MgeApplicationMentor.find(:all, :conditions =>{:Application_Key => application_key})
	end
	
end