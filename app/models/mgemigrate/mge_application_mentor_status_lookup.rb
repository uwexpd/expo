class MgeApplicationMentorStatusLookup < MgeMigrate
	set_table_name "Application_Mentor_Status_Lookup"
	set_primary_key "Application_Mentor_Status_Key"
	
	belongs_to :mge_student, :class_name => "MgeStudent", :foreign_key => "Student_Key"
	
	has_many :mentor_links, :class_name => "MgeApplicationMentor", :foreign_key => "Application_Mentor_Status_Key"
	
end