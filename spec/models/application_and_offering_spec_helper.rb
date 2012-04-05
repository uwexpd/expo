module ApplicationAndOfferingSpecHelper
	def application_for_offering_attributes
		{
			:project_title => "Test Project",
			:project_description => "The test project description"
		}
	end
	def offering_attributes
		{ 
			:name => "Test Offering",
			:description => "This is a test offering.",
			:deadline => (Time.now - 3.month),
			:open_date => (Time.now - 6.month)
		}
	end
	#  ::::Stuff to get set up for some tests::::
	# offering.uses_interviews
	# application.interview_committee_decision_type_id
	#		interview_committee_decision_types (need two entries: Yes | No)
	# application.application_review_decision_type_id
	# 		offering.application_review_decision_types (need to make three entries: Yes, Interview | Yes | No)
	# 
	# 
	# IF INTERVIEW
	#  appl_for_offering.application_review_decision_type_id = review_decisions.find(:first, :conditions => {:title => "Yes, Interview"}).id
	#  appl_for_offering.application_interview_decision_type_id = 1 for yes and 2 for no
	#  appl_for_offering.application_statuses << ApplicationStatus.create(:application_status_type_id => CREATE_FOR_ID)
	#  appl_for_offering.current_application_status_id = appl_for_offering.application_statuses.last.id
end