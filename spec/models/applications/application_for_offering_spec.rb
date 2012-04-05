require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ApplicationForOffering do
	
	describe "basic creation" do
		before(:each) do
			@application_for_offering = ApplicationForOffering.new
		end

		it "new application should not be valid without a person_id (of a student) and offering_id" do
			@application_for_offering.should_not be_valid
		end
		
		it "new application should be valid with a person_id (of a student) and offering_id" do
			@application_for_offering = Factory.create(:basic_app)
			@application_for_offering.should be_valid
		end

	end
	
	describe "find out if the application was awarded or not from reviewers" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
			@application_for_offering.set_status('test',false)
		end
		
		it "should return not awared when no review decision has been made" do
			@application_for_offering.application_review_decision_type .should be_nil
			@application_for_offering.should_not be_awarded
		end
		
		it "should return awared when they were awarded" do
			@application_for_offering.application_review_decision_type = ApplicationReviewDecisionType.create(:application_status_type_id => @application_for_offering.application_statuses[0].id, :yes_option => 1)
			@application_for_offering.application_review_decision_type.should_not be_nil
			@application_for_offering.should be_awarded
		end
		
		it "should return not awared when they were not awarded" do
			@application_for_offering.application_review_decision_type = ApplicationReviewDecisionType.create(:application_status_type_id => @application_for_offering.application_statuses[0].id)
			@application_for_offering.application_review_decision_type .should_not be_nil
			@application_for_offering.should_not be_awarded
		end
		
	end
	
	describe "find out if the application was awarded or not from interviewers" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app, :offering => (Factory.create(:interview_offering)))
			@application_for_offering.set_status('test',false)
		end
		
		it "should return awarded when the interview awarded them" do
			@application_for_offering.application_interview_decision_type = ApplicationInterviewDecisionType.create(:yes_option => 1)
			@application_for_offering.should be_awarded
		end
		
		it "should return awarded when the interview awarded them and the review decision was yes" do
			@application_for_offering.application_review_decision_type = ApplicationReviewDecisionType.create(:application_status_type_id => @application_for_offering.application_statuses[0].id, :yes_option => 1)
			@application_for_offering.application_interview_decision_type = ApplicationInterviewDecisionType.create(:yes_option => 1)
			@application_for_offering.should be_awarded
		end
		
		it "should return not awarded when the interview didn't award them" do
			@application_for_offering.application_interview_decision_type = ApplicationInterviewDecisionType.create
			@application_for_offering.should_not be_awarded
		end
		
		it "should return not awarded when the interview didn't award them and the review decision was yes" do
			@application_for_offering.application_review_decision_type = ApplicationReviewDecisionType.create(:application_status_type_id => @application_for_offering.application_statuses[0].id, :yes_option => 1)
			@application_for_offering.application_interview_decision_type = ApplicationInterviewDecisionType.create
			@application_for_offering.should_not be_awarded
		end
		
		it "should return not awarded when the interview has not made a decision yet but the review decision was yes" do
			@application_for_offering.application_review_decision_type = ApplicationReviewDecisionType.create(:application_status_type_id => @application_for_offering.application_statuses[0].id, :yes_option => 1)
			@application_for_offering.should_not be_awarded
		end
		
		it "should return not awarded when the interview has not made a decision yet" do
			@application_for_offering.should_not be_awarded
		end
	end
	
	describe "setting an application's status" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
		end
		
		it "should never return a nil status" do
			@application_for_offering.status.should_not be_nil
		end

		it "should create a new application_status record if the requested status has not been set for this application before" do
			original_size = @application_for_offering.application_statuses.size
			@application_for_offering.set_status('new_status')
			@application_for_offering.application_statuses.size.should == original_size + 1
		end

		it "should ceate a new application_status_type record if the requested status type does not exist in the list of types" do
			original_count = ApplicationStatusType.count
			@application_for_offering.set_status('completely_new_status_type')
			ApplicationStatusType.count.should == original_count + 1
		end

		it "should not create a new application_status_type record if the requested status type already exists in the list of types" do
			@application_for_offering.set_status('same_status_type')
			original_count = ApplicationStatusType.count
			@application_for_offering.set_status('same_status_type')
			ApplicationStatusType.count.should == original_count
		end

		it "should return an ApplicationStatus object" do
			@application_for_offering.set_status('setting_status').should be_instance_of(ApplicationStatus)
		end

		it "should produce a pretty description from the name when creating a new status type with no description" do
				@application_for_offering.set_status('make_this_pretty')
				@application_for_offering.status.description.should == 'Make This Pretty'
		end

	end
	
	describe "creating and setting awards" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app, :offering => (Factory.create(:award_offering)))
			@award_attributes = [{:id => @application_for_offering.awards[0].id,
											:amount_requested => 1000,
											:amount_approved => 1000,
											:amount_awarded => 900
											}]
		end
		
		it "should change the award information when you pass it the new award information" do
			@application_for_offering.award_attributes=(@award_attributes)
			@application_for_offering.awards[0].amount_requested.should == 1000
			@application_for_offering.awards[0].amount_approved.should == 1000
			@application_for_offering.awards[0].amount_awarded.should == 900
			
		end
		
	end
	
	describe "printing out award information" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering, :amount_requested => 2000, :amount_awarded => 1500)
			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering, :amount_requested => 3000, :amount_awarded => 2500)
		end
		
		it "should print out the awards in a comma separated list" do
			@application_for_offering.award_list.should == "Test 2000: $2,000.00 (Awarded $1,500.00), Test 2000: $3,000.00 (Awarded $2,500.00)"
		end
		
		it "should print out the total recieved amount" do
			@application_for_offering.total_requested_award_amount.should == 4000.0
		end
		
		it "should print out the total requested amount when none has been given" do
			@application_for_offering.awards[0].amount_awarded = nil
			@application_for_offering.awards[1].amount_awarded = nil
			@application_for_offering.awards[0].save!
			@application_for_offering.awards[1].save!
			
			@application_for_offering.total_requested_award_amount.should == 5000.0
		end
		after(:each) do
			qc = QuarterCode.all
			qc.each do |code|
				code.destroy
				code.save!
			end
		end
	end
	
	describe "reviewer functions" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
			@reviewer =  Factory.create(:person)
			@committee = Committee.create(:name => "test committee")
			@committee_member = CommitteeMember.create(:committee_id => @committee.id, :person_id => @reviewer.id)

		end
		
		it "should add a reviewer directly when passed an id" do
			@application_for_offering.add_reviewer(@reviewer.id)
			@application_for_offering.reviewers[0].offering_reviewer_id.should == @reviewer.id
		end
		
		it "should drop a reviewer that had there id passed in" do
			@application_for_offering.add_reviewer(@reviewer.id)
			@application_for_offering.reviewers[0].offering_reviewer_id.should == @reviewer.id
			@application_for_offering.drop_reviewer(@reviewer.id)
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.reviewers.should == []
		end
		
		it "should add a reviewer my a committee member id when a part of a committee" do
			@application_for_offering.add_reviewer(@committee_member)
			@application_for_offering.reviewers[0].committee_member_id.should == @committee_member.id
		end
		
		it "should drop a reviewer that has a commitee member object passed in" do
			@application_for_offering.add_reviewer(@committee_member)
			@application_for_offering.reviewers[0].committee_member_id.should == @committee_member.id
			@application_for_offering.drop_reviewer(@committee_member)
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.reviewers.should == []
		end
		
		it "should return true when the reviewers are full and falsae when not" do
			# min_number_of_reviews_per_applicant -- set in Factory
			@application_for_offering.add_reviewer(@reviewer.id)
			@application_for_offering.should_not be_reviewers_full
			
			@application_for_offering.add_reviewer(@committee_member)
			@application_for_offering.reviewers.size.should == 2
			
			@application_for_offering.should be_reviewers_full
		end
	end
	
	describe "mentor functions" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
		end
		
		it "should have a mentor vaule equal to the size set in the offering" do
			# min_number_of_mentors -- set in Factory
			@application_for_offering.mentors.size.should == Factory.attributes_for(:offering)[:min_number_of_mentors]
		end
		
		it "should update a mentor when you pass a valid mentor id along with a hash of attributes" do
			mentor = Factory.create(:mentor, :application_for_offering_id => @application_for_offering.id)
			@application_for_offering.mentor_attributes=({@application_for_offering.mentors[0].id => mentor.attributes.except(:id)})
			@application_for_offering.mentors[0].save!
			@application_for_offering.mentors[0].person_id.should == mentor.person_id
			@application_for_offering.mentors[0].application_for_offering_id.should ==  @application_for_offering.id
		end
		
	end
	
	describe "other award types" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
			@offering_other_award_type = Factory.create(:offering_other_award_type)
			other_award_attributes = {@offering_other_award_type.id => {
															:secured => "1", 
															:application_for_offering_id => @application_for_offering.id,
															}}
			@application_for_offering.other_award_attributes=(other_award_attributes)
			@application_for_offering.save_awards
		end
		
		it "should create another award type when secured is set to 1" do
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.other_awards[0].title.should == "Test Award"
		end
		
		it "should delete another award type when secured is set to 0" do
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.other_awards[0].title.should == "Test Award"
			other_award_attributes_two = {@offering_other_award_type.id => {
															:secured => "", 
															:application_for_offering_id => @application_for_offering.id,
															}}
			@application_for_offering.other_award_attributes=(other_award_attributes_two)
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.other_awards[0].should be_nil
		end
	end
	
	describe "application group members" do
		before(:each) do
			@application_for_offering = Factory.create(:basic_app)
			@group_member_attributes = { "" => {
															:id => "",
															:email => 'test@test.test',
															:firstname => 'Philip',
															:lastname => 'Fry',
															:uw_student => false,
															:application_for_offering_id => @application_for_offering.id,
															:validate_nominated_mentor => false
															}
														}
		end
		
		it "should add a group member that is not part of the UW" do
			@application_for_offering.group_member_attributes=(@group_member_attributes)
			@application_for_offering.save_group_members
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.group_members[0].should_not be_nil
		end
		
		it "should add a group member that is a student at the UW" do
			@application_for_offering.group_member_attributes=@group_member_attributes.merge({"" => {:uw_student => true}})
			@application_for_offering.save_group_members
			application_for_offering_id = @application_for_offering.id
			@application_for_offering = ApplicationForOffering.find_by_id(application_for_offering_id)
			@application_for_offering.group_members[0].should_not be_nil
		end
	end
	
	describe "application file attributes" do
		before(:each) do
			@offering_question = Factory.create(:offering_question)
			@application_for_offering = Factory.create(:basic_app, :offering => @offering_question.offering_page.offering)
		end
		
		it "should edit the file attributes when passeing new info to them" do
			@application_for_offering.file_attributes=([{:id => @application_for_offering.files[0].id,
																		:title => "Test File",
																		:description => "Test file description"
																		}])
			@application_for_offering.files[0].should_not be_nil															
			@application_for_offering.files[0].title.should == "Test File"
			@application_for_offering.files[0].description.should == "Test file description"
		end
	end
	
	describe "application start pages" do
		before(:each) do
			@offering_question = Factory.create(:offering_question)
			@offering_question_two = Factory.create(:offering_question, :offering_page => (Factory.create(:offering_page, :offering => @offering_question.offering_page.offering)))
			@application_for_offering = Factory.create(:basic_app, :offering => @offering_question.offering_page.offering)
		end
		
		it "should set the current application page to the one passed" do
			@application_for_offering.start_page(@application_for_offering.pages[1].offering_page_id)
			@application_for_offering.pages[1].started.should == true
			@application_for_offering.current_page_id.should == @application_for_offering.pages[1].id
		end
	end
	
end