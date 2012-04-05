require File.dirname(__FILE__) + '/../../spec_helper'

describe Student do
  before(:each) do
    @student = Student.new(:student_no => '1234567')
    @student_record = StudentRecord.find :first
    @sample_student_no = @student_record.student_no
    @sample_uw_netid = @student_record.uw_netid
    @sample_system_key = @student_record.system_key
  end

  it "should be valid" do
    @student.should be_valid
  end
  
  it "should split out the first and last names properly" do
    @student.sdb = StudentRecord.new(:student_name_lowc => "Harris,Matthew Kent")
    @student.sdb.fullname.should == 'Harris, Matthew Kent'
    @student.sdb.firstname.should == 'Matthew'
    @student.sdb.lastname.should == 'Harris'
  end
  
  it "should return the student number as a seven-digit string" do
    @student.sdb = StudentRecord.new(:student_no => "1234")
    @student.student_no.should == '0001234'
  end
  
  it "should return the student number from the SDB first if a student_record exists" do
    @student.student_no = "5678"
    @student.sdb = StudentRecord.new(:student_no => "1234")
    @student.student_no.should == "0001234"
  end
  
  it "should return the student number from the People table if a student record does not exist" do
    @student.student_no = "5678"
    @student.student_no.should == "0005678"
  end
  
  it "should find a student with a student number" do
    @student.sdb = @student_record
    @student.save
    Student.find_or_create_by_student_no(@sample_student_no).should == @student
  end

  it "should find a student with a uw_netid" do
    @student.sdb = @student_record
    @student.save
    Student.find_or_create_by_uw_netid(@sample_uw_netid).should == @student
  end
  
  it "should return nil if trying to find a student that doesn't exist in the SDB" do
    Student.find_or_create_by_student_no(1111111111111111111111).should be_nil
    Student.find_or_create_by_uw_netid('thisisaninvlaiduwnetidbecauseitistoolong').should be_nil
  end
  
  describe "updating the name when after a month and email after a week" do
	def fake_attributes
		{
			:fullname => "Fakelastname, Fakelastname Middle", 
			:firstname => "Fakefirstname", 
			:lastname => "Fakelastname", 
			:email => "fakefake"
		}
	end
	before(:each) do
		@student.sdb = @student_record
		@original_full_name = @student.fullname
		@original_first_name = @student.firstname
		@original_last_name = @student.lastname
		@original_email = @student.email
	end
	it "should update a student record when the name is different from the student db and it has been a month" do
		attrs = fake_attributes.merge({:sdb_update_at => (Time.now - 1.month - 1.day)})
		@student.update_attributes!(attrs)
		@student.save
		@student.read_attribute(:fullname).should == "Fakelastname, Fakelastname Middle"
		@student.fullname.should == @original_full_name
		@student.firstname.should == @original_first_name
		@student.lastname.should == @original_last_name
	end
	  
	  it "should not update a student record when it has been less than a month even if it is different" do
		attrs = fake_attributes.merge({:sdb_update_at => (Time.now - 1.day)})
		@student.update_attributes!(attrs)
		@student.save
		@student.fullname.should == "Fakelastname, Fakelastname Middle"
		@student.firstname.should == "Fakefirstname"
		@student.lastname.should == "Fakelastname"
	  end
	  
	  it "should update a student record when checking the email if it has been a week" do
		attrs = fake_attributes.merge({:sdb_update_at => (Time.now - 1.week - 1.day)})
		@student.update_attributes!(attrs)
		@student.save
		@student.read_attribute(:email).should == "fakefake"
		@student.email.should == @original_email
	  end
	  
	  it "should not update a student record when checking the email if it has been less than a week" do
		attrs = fake_attributes.merge({:sdb_update_at => (Time.now - 1.day)})
		@student.update_attributes!(attrs)
		@student.save
		@student.email.should == "fakefake"
	  end
  end
end

describe Student, "syncing system_keys and student_no's" do
  
  it "should update the system_key in the People table if it is null when finding a record by student_no" do
    pending "the way this is handled has changed, this test might not be needed anymore" do
      sample_sr = StudentRecord.find :first
      s2 = Student.create :student_no => sample_sr.student_no
      s2.system_key.should be_nil
      Student.find_by_student_no(sample_sr.student_no)
      s2.reload
      s2.system_key.should_not be_nil
    end
  end

  it "should update the system_key in the People table if it is null when finding a record by uw_netid" do
    pending "the way this is handled has changed, this test might not be needed anymore" do
      sample_sr = StudentRecord.find :first
      s2 = Student.create :student_no => sample_sr.student_no
      s2.system_key.should be_nil
      Student.find_by_uw_netid(sample_sr.uw_netid)
      s2.reload
      s2.system_key.should_not be_nil
    end
  end
  
end