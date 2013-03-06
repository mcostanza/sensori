require 'spec_helper'

describe PrelaunchSignup do
  before(:each) do
    @prelaunch_signup = FactoryGirl.build(:prelaunch_signup)
  end
  
  describe "validations" do
    it "should be valid given valid attributes" do
      @prelaunch_signup.valid?.should be_true
    end
    it "should be invalid without an email" do
      @prelaunch_signup.email = ''
      @prelaunch_signup.valid?.should be_false
    end
    it "should be invalid with a non-unique email" do
      @prelaunch_signup.save
      other = FactoryGirl.build(:prelaunch_signup)
      other.email = @prelaunch_signup.email
      other.valid?.should be_false
    end
  end
end
