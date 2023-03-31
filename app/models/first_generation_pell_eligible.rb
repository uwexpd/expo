# Data source:  Office of Planning and Budgeting database (AIDB)
# Export two csv files via Gnen Kim and he will provide ot us once a year
# FirstGeneration 4YrDegree_at_least_once & AcademicQtrCensusDayPellEligibleStudentInd_at_least_once
class FirstGenerationPellEligible < ActiveRecord::Base
	set_primary_key "system_key"	
	has_one :student, :primary_key => "system_key", :foreign_key => "system_key"
end
