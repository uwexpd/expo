class SympThreeGroup < SympThreeMigrate
	set_table_name "GroupTbl"
	
	set_primary_key "GroupID"
	
	has_many :symp_three_student, :class_name => "SympThreeStudent", :foreign_key => "GroupID"
	
end