require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe OfferingQuestion do
	before(:each) do
		@offering_question = Factory.create(:offering_question)
		@application_for_offering = Factory.create(:basic_app, :offering => @offering_question.offering_page.offering)
	end
	
	describe "radio buttons" do
		it "should add an error if the required radio buttons were not selected" do
			@offering_question.attribute_to_update = 'attended_info_session'
			@offering_question.display_as = 'radio_options'
			@offering_question.required = false
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not add an error if the required radio buttons were selected" do
			@application_for_offering.attended_info_session = true
			@application_for_offering.save!
			
			@offering_question.attribute_to_update = 'attended_info_session'
			@offering_question.display_as = 'radio_options'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
	end
	
	describe "application text" do
		it "should add an error when required application text is blank" do
			@offering_question.attribute_to_update = 'test'
			@offering_question.display_as = 'application_text'
			@offering_question.required = false
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not add an error when required application text is not blank" do
			@application_for_offering.texts << ApplicationText.create(:title=>"test")
			@application_for_offering.texts[0].body=("body body")
			@application_for_offering.save!
			
			@offering_question.attribute_to_update = 'test'
			@offering_question.display_as = 'application_text'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
		it "should add an error when application text has too many words" do
			@application_for_offering.texts << ApplicationText.create(:title=>"test")
			@application_for_offering.texts[0].save!
			@application_for_offering.texts[0].body=("body body body body body body body body body body body body body body body body body body body body body body body body body body body body")
			@application_for_offering.texts[0].versions[0].save!
			@application_for_offering.save!
			
			@offering_question.attribute_to_update = 'test'
			@offering_question.display_as = 'application_text'
			@offering_question.required = true
			@offering_question.word_limit = 200
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.word_limit = 5
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
	end
	
	describe "application category" do
		before(:each) do
			@offering_application_category = Factory.create(:offering_application_category, :offering => @application_for_offering.offering, 
																												:offering_application_type => (Factory.create(:offering_application_type, :offering => @application_for_offering.offering, 
																														:workshop_event =>(Factory.create(:event, :offering => @application_for_offering.offering)))))
			@offering_application_category.save!
			@application_for_offering.application_category_id = @offering_application_category.id
			@application_for_offering.save!
		end
		it "should add an error when the application category is required and blank" do
			@application_for_offering.application_category_id = nil
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'application_category_id'
			@offering_question.display_as = 'application_category'
			@offering_question.required = false
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not add an error when the application category is required and not blank" do
			@offering_question.attribute_to_update = 'application_category_id'
			@offering_question.display_as = 'application_category'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
		it "should add an error when there should be another application category title but it is blank" do
			@offering_application_category.other_option = 1
			@offering_application_category.save!
			@offering_question.attribute_to_update = 'application_category_id'
			@offering_question.display_as = 'application_category'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not add an error when there should be another application category title but it is not blank" do
			@offering_application_category.other_option = 1
			@offering_application_category.save!
			@application_for_offering.other_category_title = "Another Test Category"
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'application_category_id'
			@offering_question.display_as = 'application_category'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
	end
	
	describe "fullname" do
		it "should add an error when the firstname is missing" do
			@application_for_offering.person.firstname = ''
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'fullname'
			@offering_question.display_as = 'readonly'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should add an error when the lastname is missing" do
			@application_for_offering.person.lastname = ''
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'fullname'
			@offering_question.display_as = 'readonly'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should add an error when the firstname and lastname are missing" do
			@application_for_offering.person.lastname = ''
			@application_for_offering.person.firstname = ''
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'fullname'
			@offering_question.display_as = 'readonly'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not add an error when the firstname and lastname are not missing" do
			@application_for_offering.person.lastname.should == 'Fry'
			@application_for_offering.person.firstname.should == 'Philip'
			@offering_question.attribute_to_update = 'fullname'
			@offering_question.display_as = 'readonly'
			@offering_question.required = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
		
	end
	describe "length tests" do
		it "should not allow a feild that has too many characters" do
			@application_for_offering.project_title = "Test Title that is Over 10 in Character Length"
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'project_title'
			@offering_question.display_as = 'short_response'
			@offering_question.character_limit = 100
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.character_limit = 10
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not allow a feild that has too many words" do
			@application_for_offering.project_description = "Test Description that is Over 20 in Words Length by adding some text to the end of the description that will add words"
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'project_description'
			@offering_question.display_as = 'short_response'
			@offering_question.word_limit = 100
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
			@offering_question.word_limit = 10
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
	end
	describe "phone number" do
		it "should not allow an invalid phone number when a valid one is required" do
			@application_for_offering.person.phone = '123215'
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'phone'
			@offering_question.model_to_update = 'person'
			@offering_question.display_as = 'short_response'
			@offering_question.require_valid_phone_number = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should allow a valid phone number when valid one is required" do
			@application_for_offering.person.phone = '2012123215'
			@application_for_offering.save!
			@offering_question.attribute_to_update = 'phone'
			@offering_question.model_to_update = 'person'
			@offering_question.display_as = 'short_response'
			@offering_question.require_valid_phone_number = true
			@offering_question.add_errors(@application_for_offering.pages[0])
			@application_for_offering.pages[0].errors.should be_empty
		end
	end
	
	describe "award errors" do
		it "should not allow duplicate award quarters" do
			@quarter = Factory.create(:quarter)
			@application_for_offering.awards = []
			@application_for_offering.awards << Factory.create(:application_award ,:application_for_offering => @application_for_offering, :requested_quarter => @quarter)
			@application_for_offering.awards << Factory.create(:application_award ,:application_for_offering => @application_for_offering, :requested_quarter => @quarter)
			@application_for_offering.save!
			@offering_question.display_as = 'awards'
			@offering_question.add_errors(@application_for_offering.pages[0])
			#@application_for_offering.pages[0].errors.should == "test" # to see error output in terminal
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		it "should not allow a blank quarter" do
		  pending "this test is not working anymore" do
		  	@application_for_offering.offering.min_number_of_awards = 2
  			@application_for_offering.offering.save!
  			@application_for_offering.awards = []
  			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering)
  			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering, :requested_quarter => nil)
  			@application_for_offering.save!
  			@offering_question.display_as = 'awards'
  			@offering_question.add_errors(@application_for_offering.pages[0])
  			#@application_for_offering.pages[0].errors.should == "test" # to see error output in terminal
  			@application_for_offering.pages[0].errors.should_not be_empty
		  end
		end
		it "should not allow a out of order quarters" do
		  pending "this test is not working anymore" do
  			#### Can only use quarter code factory 4 times Expo assumes there are only 4
  			@application_for_offering.offering.min_number_of_awards = 2
  			@application_for_offering.offering.save!
  			@application_for_offering.awards = []
  			out_of_order_award = Factory.create(:application_award , :application_for_offering => @application_for_offering)
  			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering)
  			@application_for_offering.awards << out_of_order_award
  			@application_for_offering.save!
  			@offering_question.display_as = 'awards'
  			@offering_question.add_errors(@application_for_offering.pages[0])
  			#@application_for_offering.pages[0].errors.should == "test" # to see error output in terminal
  			@application_for_offering.pages[0].errors.should_not be_empty
		  end
		end
		it "should not allow skipping two quarters" do
			#### Can only use quarter code factory 4 times Expo assumes there are only 4
			@application_for_offering.offering.min_number_of_awards = 2
			@application_for_offering.offering.save!
			@application_for_offering.awards = []
			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering)
			move_quarter_code_to_next = Factory.create(:quarter)
			move_quarter_code_to_next = Factory.create(:quarter)
			@application_for_offering.awards << Factory.create(:application_award , :application_for_offering => @application_for_offering)
			@application_for_offering.save!
			@offering_question.display_as = 'awards'
			@offering_question.add_errors(@application_for_offering.pages[0])
			#@application_for_offering.pages[0].errors.should == "test" # to see error output in terminal
			@application_for_offering.pages[0].errors.should_not be_empty
		end
		after(:each) do
			qc = QuarterCode.all
			qc.each do |code|
				code.destroy
				code.save!
			end
		end
	end
end





















































