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
      helper.stub!(:request).and_return(mock('request', :user_agent => "iphone"))
      helper.is_mobile_device?.should be_true
    end
    it "should return true if the user agent matches a mobile device (case insensitive)" do
      helper.stub!(:request).and_return(mock('request', :user_agent => "Android"))
      helper.is_mobile_device?.should be_true
    end
    it "should return false if the user agent does not match a mobile device" do
      helper.stub!(:request).and_return(mock('request', :user_agent => "Firefox"))
      helper.is_mobile_device?.should be_false
    end
    it "should not shit if there is no user agent" do
      helper.stub!(:request).and_return(mock('request', :user_agent => nil))
      lambda { helper.is_mobile_device? }.should_not raise_error
      helper.is_mobile_device?.should be_false
    end
  end
  
end