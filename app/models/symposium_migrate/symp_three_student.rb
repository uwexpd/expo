class SympThreeStudent < SympThreeMigrate
	set_table_name "StudentTbl"
	
	set_primary_key "StNum"
	
	belongs_to :symp_group, :class_name => "SympThreeGroup", :foreign_key => "GroupID"
	
end