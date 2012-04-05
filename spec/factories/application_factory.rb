# Create an App that has a student and offering built for it
Factory.define :basic_app, :class => ApplicationForOffering do |u|
	u.association :person, :factory => :student
	u.association :offering, :factory => :offering
	u.project_title "Test Project"
	u.project_description "The test project description"
end

# Create a very basic ApplicationAward
Factory.define :application_award do |a|
	a.association :application_for_offering, :factory => :basic_app
	a.association :requested_quarter, :factory => :quarter
end

# Create an ApplicationOtherAward
Factory.define :application_other_award do |a|
	a.association :offering_other_award_type, :factory => :offering_other_award_type
end

# Create an ApplicationGroupMember
Factory.define :application_group_member do |a|
	a.association :application_for_offering, :factory => :basic_app
	a.email 'expohelp@u.wahington.edu'
	a.firstname 'Philip'
	a.lastname 'Fry'
	a.uw_student false
end
