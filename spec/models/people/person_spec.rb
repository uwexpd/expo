require File.dirname(__FILE__) + '/../../spec_helper'

describe Person do
  
  before(:each) do
      @person = Factory.build(:person)
      @service_learning_course = Factory.build(:service_learning_course)
      @position = Factory.create(:service_learning_position)    
      #@placement = ServiceLearningPlacement.create(:service_learning_position_id => @position, :service_learning_course_id => @service_learning_course, :unit_id => 1, :position => @position)
  end
  
  it "should be able to be placed into a placement" do
     @person.place_into(@position, @service_learning_course)          
  end
  
end