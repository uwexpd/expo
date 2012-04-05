require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ApplicationStatusType do
  before(:each) do
    @status_type = ApplicationStatusType.new
  end

  it "should require a name" do
    @status_type.should_not be_valid
    @status_type.name = 'test'
    @status_type.should be_valid
  end

  
  it "should not allow more than one of the same name" do
    @type1 = ApplicationStatusType.create(:name => 'test')
    @type2 = ApplicationStatusType.new(:name => 'test')
    @type2.should_not be_valid
    @type2.name = 'test2'
    @type2.should be_valid
  end
  
end
