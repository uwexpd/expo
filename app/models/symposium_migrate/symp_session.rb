class SympSession < SympMigrate
	set_table_name "tlkpSession"
	
	set_primary_key "SessionID"
	
	has_many :symp_group, :class_name => "SympGroup", :foreign_key => "SessionID"
	
end