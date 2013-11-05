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
      @current_member = double(Member, :admin? => true)
    end
    it "should return true when @member is set and @member.admin is true" do
      helper.admin?.should be_true
    end
    it "should return false when @member is set and @member.admin if false" do
      @current_member.stub(:admin?).and_return(false)
      helper.admin?.should be_false
    end
    it "should return false when @member is not set" do
      @current_member = nil
      helper.admin?.should be_false
    end
  end

  describe "#active_if(condition)" do
    it "should return 'active' if the condition is true" do
      helper.active_if(true).should == 'active'
    end
    it "should return nil otherwise" do
      helper.active_if(false).should == nil
      helper.active_if(nil).should == nil
    end
  end

  describe "#member_profile_page?" do
    before do
      helper.stub(:member_profile_path).and_return('/user')
      helper.stub(:current_page?).and_return(true)
      @member = double(Member)
    end
    it "should return true if there is a @member set and the current page is that member's profile" do
      helper.should_receive(:member_profile_path).with(@member).and_return('/user')
      helper.should_receive(:current_page?).with('/user').and_return(true)
      helper.member_profile_page?.should be_true
    end
    it "should return false if there is no @member set" do
      @member = nil
      helper.member_profile_page?.should be_false
    end
    it "should return false if there is a @member set but the current page is not their profile" do
      helper.should_receive(:current_page?).and_return(false)
      helper.member_profile_page?.should be_false
    end
  end
end
