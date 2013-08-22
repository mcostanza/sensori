require 'spec_helper'

describe ApplicationHelper do

  it "should have a MOBILE_USER_AGENTS constant" do
    ApplicationHelper::MOBILE_USER_AGENTS.should_not be_nil
  end
  it "should have a MOBILE_USER_AGENT_REGEX constant" do
    ApplicationHelper::MOBILE_USER_AGENT_REGEX.should_not be_nil
  end
  
  describe "#is_mobile_device?" do
    it "should return true if the user agent matches a mobile device" do
      helper.stub(:request).and_return(double('request', :user_agent => "iphone"))
      helper.is_mobile_device?.should be_true
    end
    it "should return true if the user agent matches a mobile device (case insensitive)" do
      helper.stub(:request).and_return(double('request', :user_agent => "Android"))
      helper.is_mobile_device?.should be_true
    end
    it "should return false if the user agent does not match a mobile device" do
      helper.stub(:request).and_return(double('request', :user_agent => "Firefox"))
      helper.is_mobile_device?.should be_false
    end
    it "should not shit if there is no user agent" do
      helper.stub(:request).and_return(double('request', :user_agent => nil))
      lambda { helper.is_mobile_device? }.should_not raise_error
      helper.is_mobile_device?.should be_false
    end
  end

  describe "#admin?" do
    before do
      @member = double(Member, :admin? => true)
    end
    it "should return true when @member is set and @member.admin is true" do
      helper.admin?.should be_true
    end
    it "should return false when @member is set and @member.admin if false" do
      @member.stub(:admin?).and_return(false)
      helper.admin?.should be_false
    end
    it "should return false when @member is not set" do
      @member = nil
      helper.admin?.should be_false
    end
  end
  
end
