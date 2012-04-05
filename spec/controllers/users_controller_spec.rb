require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do

	integrate_views
	
	before(:each) do
		@user = Factory.create(:user)
		@user.save!
	end
	
	describe "show new user form" do
		it "should show the new user form to a new user" do
			post :new
			response.should render_template('users/new')
		end
	end
	
	describe "update the user profile" do
		it "should allow a user to update their profile with valid information" do
			current_user = @user
			controller.stub!(:current_user).and_return(current_user)
			
			post :update, :user => {:firstname => "Bob", :lastname => "Bobbo", :person_attributes => {:email => "bob@test.com"}}
			flash[:notice].should have_text("Thanks for updating your profile!")
		end
		it "should not allow a user to update their profile with invalid information" do
			current_user = @user
			controller.stub!(:current_user).and_return(current_user)
			
			post :update, :user => {:firstname => "", :lastname => "", :person_attributes => {:email => ""}}
			response.should have_text(/Please correct the following problems with your user record./)
		end
	end
	
	describe "create the user" do
		it "should not allow a user to be created with invalid information" do
			post :create, :user => {  
				:person_attributes => {
					}}
			response.should render_template('users/new')
			response.should have_text(/There were problems with the following fields:/)
		end
		it "should allow a user to be created with valid information" do
			post :create, :user => { 
											:email => 'expohelp@u.wahington.edu',
											:login => 'tester',
											:password => 'secret' ,
											:password_confirmation => 'secret' ,
											:person_attributes => 
												{
												:firstname => 'Philip',
												:lastname => 'Fry',
												:email => 'expohelp@u.wahington.edu',
												:salutation => 'Mr.',
												:address1 => 'Planet Express Building',
												:city => 'New New York',
												:state => 'New York',
												:zip => '10293'
												}
											}
			response.should redirect_to('/')
			flash[:notice].should have_text("Thanks for signing up!")
		end
	end
	
	describe "display the user profile" do
		it "should display a profile for a valid user without errors" do
			current_user = @user
			controller.stub!(:current_user).and_return(current_user)
			post :profile
			response.should render_template('users/profile')
		end
		it "should display errors on a profile for an invalid user" do
			@user.person.require_validations = false
			@user.person.firstname = nil
			@user.person.save!
			current_user = @user
			controller.stub!(:current_user).and_return(current_user)
			post :profile
			response.should have_text(/Firstname can't be blank/)
		end
	end
	
end