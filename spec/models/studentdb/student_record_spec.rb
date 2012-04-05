require File.dirname(__FILE__) + '/../../spec_helper'

describe StudentRecord do
	before(:each) do
		@sdb = StudentRecord.new(
			:student_name_lowc => "O'Keefe,Lee Patrick",
			:uw_netid => "fakenetid",
			:class => 4,
			:yr_of_birth => 88,
			:mth_of_birth => 1,
			:day_of_birth => 1,
			:system_key => 1234567,
			:student_no => 1234567
			)
	end

	it "should print out the names right" do
		@sdb.fullname.should == "O'Keefe, Lee Patrick"
		@sdb.firstname.should == "Lee"
		@sdb.lastname.should == "O'Keefe"
	end
	
	it "should find out the class standing" do
		@sdb.class_standing.should == 4
	end
	
	it "should make a email from a uw_netid" do
		@sdb.email.should == "fakenetid@u.washington.edu"
	end
	
	it "should make a birth date from a year month and day" do
		@sdb.birth_date.should == Date.new(1988, 1, 1)
	end
	
 end