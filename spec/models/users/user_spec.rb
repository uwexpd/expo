# put in /spec/models/users folder
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/user_spec_helper')

describe User do

	include UserSpecHelper

	before(:each) do
		@user = User.new
		@person = Person.new
		@person.attributes = valid_person_attributes
		@person.save!
		@user.person_id = @person.id
	end
	
	it "should be invalid without a login (username)" do
		@user.attributes = valid_user_attributes.except(:login)
		@user.should_not be_valid
		@user.login = "valid_login"
		@user.should be_valid
	end
	
	it "should be invalid with a login (username) of less than 3 characters" do
		@user.attributes = valid_user_attributes
		@user.login = "no"
		@user.should_not be_valid
		@user.login = "valid_login"
		@user.should be_valid
	end
	
	it "should be invalid without a password" do
		@user.attributes = valid_user_attributes.except(:password)
		@user.should_not be_valid
		@user.password = "secret"
		@user.should be_valid
	end
	
	it "should be invalid without a password_confirmation" do
		@user.attributes = valid_user_attributes.except(:password_confirmation)
		@user.should_not be_valid
		@user.password_confirmation = "secret"
		@user.should be_valid
	end
	
	it "should be invalid when the password and password_confirmation dont match" do
		@user.attributes = valid_user_attributes.except(:password_confirmation)
		@user.password_confirmation = "not_secret"
		@user.should_not be_valid
		@user.password_confirmation = "secret"
		@user.should be_valid
	end
	
	it "should be invalid with a password and password_confirmation under 6 characters" do
		@user.attributes = valid_user_attributes
		@user.password_confirmation = "no"
		@user.password = "no"
		@user.should_not be_valid
		@user.password_confirmation = "secret"
		@user.password = "secret"
		@user.should be_valid
	end
	
	it "should be invalid without a person_id" do
		@user.attributes = valid_user_attributes
		@user.person_id = nil
		@user.should_not be_valid
		@user.person_id = @person.id
		@user.should be_valid
	end
	
	it "should be invalid if login is already taken" do
		@user.attributes = valid_user_attributes
		@user.save!
		@user2 = User.new
		@user2.attributes = valid_user_attributes
		@user2.person_id = @person.id
		@user2.should_not be_valid
		@user2.login= "anothertester"
		@user2.should be_valid
	end
	
	describe "get the full name" do
		before(:each) do
			@user.attributes = valid_user_attributes
			@user.save!
		end
		it "should print out the users first and last name when they have both" do
			@user.fullname.should == "Philip Fry"
		end
		it "should print out a users login when they have no name" do
			@user.person.firstname = nil
			@user.person.lastname = nil
			@user.fullname.should == "tester"
		end
		it "should print out formal first and last name with the nickname" do
			@user.person.nickname = "Bender"
			@user.firstname_first.should == "Philip (Bender) Fry"
		end
	end
	
end