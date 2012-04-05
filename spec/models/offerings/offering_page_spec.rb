require File.dirname(__FILE__) + '/../../spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../application_and_offering_spec_helper')

describe OfferingPage do

	include ApplicationAndOfferingSpecHelper

  before(:each) do
    @offering_page = OfferingPage.new
    @offering = Offering.new(offering_attributes)
    @offering.save
    @p1 = @offering.pages.create :ordering => 1
    @p2 = @offering.pages.create :ordering => 2
    @p3 = @offering.pages.create :ordering => 3
  end

  it "should be valid" do
		@offering_page.should be_valid
  end
  
  it "should provide the next page in the offering or nil if this is the last page" do
    @p1.next.should == @p2
    @p2.next.should == @p3
    @p3.next.should == nil
  end
  
  it "should provide the previous page in the offering or nil if this is the first page" do
    @p1.prev.should == nil
    @p2.prev.should == @p1
    @p3.prev.should == @p2
  end
  
  it "should not allow two of the same page ordering within the same offering" do
    @offering.pages.create(:ordering => 1).should_not be_valid
  end
  
  it "should allow two of the same page ordeing for different offerings" do
    @o1 = Offering.new(offering_attributes)
    @o2 = Offering.new(offering_attributes)
    @o1.save
    @o2.save
    @o1p1 = @o1.pages.create :ordering => 1
    @o2p1 = @o2.pages.create :ordering => 1
    @o1p1.should be_valid
    @o2p1.should be_valid
    @o1.should be_valid
    @o2.should be_valid
  end
  
end
