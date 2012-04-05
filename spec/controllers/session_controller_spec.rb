require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionController do

	integrate_views
	
	before(:each) do
		@user = Factory.create(:user, :login => "tester")
	end
	
	describe "show login form" do
		it "should show the login form to a new session" do
			post :new
			response.should render_template('session/new')
		end
	end
	
	describe "logging in to expo" do
	
		it "should not allow a user with an invalid login to login" do
			post :create, :login => "no_such_user", :password => "secret"      
			#flash[:error].should have_text("Authentication failed.")
			response.should render_template('session/new')
		end
		
		it "should not allow a user with an invalid password to login" do
			post :create, :login => "tester", :password => "not_secret"      
			#flash[:error].should have_text("Authentication failed.")
			response.should render_template('session/new')
		end
		
		it "should allow a user with an valid password to login" do
			post :create, :login => "tester", :password => "secret"      
			response.should redirect_to('/')  
			flash[:notice].should have_text("Logged in successfully")
		end
		
		it "should allow a user with a valid uwnetid authentication to login"
		
		it "should allow a user with a valid openid authentication to login"
		
	end
	
	describe "resetting a password" do 
	
		it "should not allow an invalid login to get an email sent if they forgot their password" do
			post :forgot, :commit => "true", :login => "not_tester"
			flash[:error].should have_text("That username does not exist.")
		end
		
		it "should allow a valid login to get an email sent if they forgot their password" do
			post :forgot, :commit => "true", :login => "tester"
			flash[:notice].should have_text("Instructions have been sent to your email address that will tell you how to reset your password.")
		end
		
		it "should not allow a password to be reset if the reset link is wrong" do
			post :reset_password, :user_id => @user.id, :token => "faketoken"
			flash[:error].should have_text("That password reset link is invalid. Please try again.")
			#response.should redirect_to(:action => "forgot")
		end
		
		it "should alllow a password to be reset if the reset link is valid" do
			@user.create_token
			post :reset_password, :user_id => @user.id, :token => @user.token, :user => {:password => "new_secret", :password_confirmation => "new_secret"}
			flash[:notice].should have_text("Your password was successfully reset.")
			response.should redirect_to(root_url)
		end
		
		it "should not alllow a password to be reset if the reset link has been used" do
			@user.create_token
			post :reset_password, :user_id => @user.id, :token => @user.token, :user => {:password => "new_secret", :password_confirmation => "new_secret"}
			flash[:notice].should have_text("Your password was successfully reset.")
			response.should redirect_to(root_url)
			post :reset_password, :user_id => @user.id, :token => @user.token
			flash[:error].should have_text("That password reset link is invalid. Please try again.")
		end
		
		it "should not alllow a password to be reset if the passwords do not match" do
			@user.create_token
			post :reset_password, :user_id => @user.id, :token => @user.token, :user => {:password => "new_not_secret", :password_confirmation => "new_secret"}
			response.should have_text(/Password doesn't match confirmation/)
		end
		
	end
	
	describe "logging out of expo" do
	
		it "should log out a logged in user" do
			@user.stub!(:logged_in?).and_return(true)
			post :destroy
			flash[:notice].should have_text("You have been logged out.")
			response.should redirect_to('/')  
		end
		
	end
	
end









