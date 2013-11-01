require 'spec_helper'

describe MembersHelper do
  describe "#member_location(member)" do
    before do
      @member = Member.new(:city => "Boston", :country => "United States")
    end
    it "should return a formatted string of the members location" do
      helper.member_location(@member).should == "Boston, United States"
    end
    it "should return only the city when country is unavailable" do
      @member.country = nil
      helper.member_location(@member).should == "Boston"
    end
    it "should return only the country when city is unavailable" do
      @member.city = ''
      helper.member_location(@member).should == "United States"
    end
    it "should return an empty string when neither is set" do
      @member.city = nil
      @member.country = nil
      helper.member_location(@member).should == ""
    end
  end
end
