require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ServiceLearningController do    
  
  before(:each) do
		@user = Factory.create(:user)
		@service_learning_course = Factory.create(:service_learning_course)
		@placement = ServiceLearningPlacement.create(:service_learning_position_id => @position, :service_learning_course_id => @service_learning_course, :unit_id => 1 )
		@position = Factory.create(:service_learning_position)
		
		controller.stub!(:current_user).and_return(@user)
		controller.stub!(:check_if_student).and_return(@user.person)
		controller.stub!(:fetch_student).and_return(@user.person)
		controller.stub!(:fetch_enrolled_service_learning_courses).and_return(@service_learning_course)
		controller.stub!(:check_enrolled_service_learning_courses).and_return(true)
		controller.stub!(:assign_service_learning_course).and_return(@service_learning_course)
		controller.stub!(:require_waiver_if_minor).and_return(false)
		controller.stub!(:check_if_already_registered).and_return(false)
		controller.stub!(:fetch_position).and_return(@position)
		controller.stub!(:check_if_registration_finalized).and_return(true)
		controller.stub!(:check_if_registration_open).and_return(true)				
	end
	
	describe "confirm the position" do
	  it "should place the student in the position" do
	    
			#Parameters: {"id"=>"9429", "controller"=>"service_learning", "student"=>{"electronic_signature"=>"Josh Lin"}, "quarter_abbrev"=>"current", "action"=>"risk", "commit"=>"Finish My Registration", "_method"=>"put"}
			
			#post :risk, :id => @position.id, :student => { :electronic_signature => 'Philip Fry'}, :enrolled_service_learning_course_ids => @service_learning_course.id
			#flash[:notice].should have_text("Service-learning registration complete.")
		end
	end

  
  
end