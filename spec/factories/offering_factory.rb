# Create an Offering
Factory.define :offering do |o|
	o.name "Test Offering"
	o.description "This is a test offering."
	o.deadline(Time.now - 3.month)
	o.open_date(Time.now - 6.month)
	o.min_number_of_reviews_per_applicant 2
	o.min_number_of_mentors 2
	o.unit_id 2
end

# Create an Offering that uses interviews
Factory.define :interview_offering, :parent => :offering do |o|
	o.uses_interviews 1
	o.award_basis "interview"
end

# Create an Offering that has one award
Factory.define :award_offering, :parent => :offering do |o|
	o.number_of_awards 1
	o.default_award_amount 2000
end

# Create an OfferingPage
Factory.define :offering_page do |o|
	o.association :offering, :factory => :offering
	o.sequence(:ordering) {|n| "#{n}" }
	o.title "Test Page"
	o.description "Test page description"
end

# Create an OfferingQuestion
Factory.define :offering_question do |o|
	o.association :offering_page, :factory => :offering_page
	o.display_as 'files'
	o.question "Is this a test?"
end

# Create an ApplicationCategory
Factory.define :application_category do |a|
	a.title "Test Category"
	a.description "This categry is a test of the categories"
end

# Create OfferingApplicationCategory
Factory.define :offering_application_category do |o|
	o.association :offering, :factory => :offering
	o.association :application_category, :factory => :application_category
	o.association :offering_application_type, :factory => :offering_application_type
	o.sequence(:sequence) {|n| "#{n}" }
end

# Create OfferingApplicationType
Factory.define :offering_application_type do |o|
	o.association :offering, :factory => :offering
	o.association :application_type, :factory => :application_type
	o.association :workshop_event, :factory => :event
end

# Create ApplicationType
Factory.define :application_type do |o|
	o.title "Test Application Type"
	o.description "This is a test description of the application type"
end

# Create an AwardType
Factory.define :award_type do |a|
	a.title "Test Award"
end

# Create an OfferingOtherAwardType
Factory.define :offering_other_award_type do |a|
	a.association :award_type, :factory => :award_type
end
