require File.dirname(__FILE__) + '/../../spec_helper'

describe PubcookieUser do
  before(:each) do
    @pubcookie_user = PubcookieUser.authenticate 'test'
  end
  
  it "should be valid with only a username and a person record" do
    @pubcookie_user.should be_valid
  end
  
  it "should return a proper email address" do
    @pubcookie_user.email.should == 'test@u.washington.edu'
  end
   
end

describe PubcookieUser, "authenticating with a UWNetID" do
  before(:each) do
    @pubcookie_user = PubcookieUser.authenticate 'test'
    @student_record = StudentRecord.find :first, :conditions => "uw_netid != ''"
    @sample_student_no = @student_record.student_no
    @sample_uw_netid = @student_record.uw_netid
  end

  it "should return an exisiting PubcookieUser if one exists" do
    #@pubcookie_user.person = Person.create(:firstname => 'First', :lastname => 'Last')
    #@pubcookie_user.save
    PubcookieUser.authenticate('test', 'password').should == @pubcookie_user
  end
  
  it "should return an existing PubcookieUser Student identity if one exists" do
    #@pubcookie_user.person = Person.create
    @pubcookie_user.identity_type = "Student"
    @pubcookie_user.save
    @pubcookie_user.should be_valid
    PubcookieUser.authenticate('test',nil,'Student').should == @pubcookie_user
  end
  
  it "should create a new PubcookieUser for a student if this UWNetID has a valid student record in UWSDB" do
    PubcookieUser.authenticate(@sample_uw_netid, 'password', 'Student').person.sdb.should == @student_record
  end
  
  it "should create a new generic Person record if the student is not found in the UWSDB" do
    PubcookieUser.authenticate('thisuwnetidshouldnotbefoundinthestudentdatabase').person.should be_valid
  end

  it "should create PubcookieUser when Student identity is required and a student record exists" do
    PubcookieUser.authenticate(@sample_uw_netid, nil, "Student").should be_valid
  end

  it "should return false if a Student identity is required but no student record exists" do
    PubcookieUser.authenticate('thisuwnetidshouldnotbefound',nil,'Student').should == false
  end  
  
  it "should default to returning the generic Person identity when there are two or more identities and no required type is specified" do
    @p1 = PubcookieUser.create :login => 'test1'; @p1.identity_type = "Student"; @p1.person = Person.create; @p1.save
    @p2 = PubcookieUser.create :login => 'test1'; @p2.identity_type = nil; @p2.person = Person.create; @p2.save
    PubcookieUser.authenticate('test1').should == @p2
  end
  
  it "should return a new Person record -- even if a Student record exists -- when no required identity type is specified" do
    PubcookieUser.authenticate(@sample_uw_netid, nil, "Student").should be_valid
    person_before_count = Person.count
    PubcookieUser.authenticate(@sample_uw_netid).should be_valid
    Person.count.should_not == person_before_count
  end
  
  it "should only create a new Person record once, the first time s/he authenticates" do
    person_before_count = Person.count
    PubcookieUser.authenticate(@sample_uw_netid).should be_valid
    PubcookieUser.authenticate(@sample_uw_netid).should be_valid
    PubcookieUser.authenticate(@sample_uw_netid).should be_valid
    Person.count.should == person_before_count + 1
  end
  
  it "should create a generic Person record if no specific identity type is required, even if there is a student record for him" do
    @p1 = PubcookieUser.authenticate(@sample_uw_netid, nil, 'Student')
    @p1.should be_valid
    PubcookieUser.authenticate(@sample_uw_netid).should_not == @p1
  end
  
  
end
