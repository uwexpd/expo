class MgeAward < MgeMigrate
	set_table_name "awards"
	set_primary_key "Award"
	
	belongs_to :mentor_links, :class_name => "MgeApplication", :foreign_key => "Award_type"
	
	def self.get_award_info(award_type)
		MgeAward.find(:first, :conditions =>{:Award_Type => award_type})
	end
	
end