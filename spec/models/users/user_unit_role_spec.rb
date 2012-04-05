require File.dirname(__FILE__) + '/../../spec_helper'

describe UserUnitRole do
  before(:each) do
    @user_unit_role = UserUnitRole.new
  end

  it "should be invalid without any values" do
    @user_unit_role.should_not be_valid
    @user_unit_role.user_id = 1
    @user_unit_role.unit_id = 1
    @user_unit_role.role_id = 1
    @user_unit_role.should be_valid
  end
  
  it "should only allow one role per unit per user per unit" do
    @u1 = UserUnitRole.new :user_id => 1, :role_id => 1, :unit_id => 1
    @u1.save
    @u1.should be_valid
	@u2 = UserUnitRole.new :user_id => 1, :role_id => 2, :unit_id => 1
    @u2.should be_valid
    @u3 = UserUnitRole.new :user_id => 1, :role_id => 1, :unit_id => 1
    @u3.should_not be_valid
    @u3 = UserUnitRole.new :user_id => 1, :role_id => 1, :unit_id => 2
    @u3.should be_valid
  end
  
end
