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

  describe "#member_profile_full_name(member)" do
    before do
      @member = Member.new(:full_name => "Steve Dods")
    end
    it "should return a muted span with the member's full name" do
      helper.member_profile_full_name(@member).should == '<span class="full-name muted">(Steve Dods)</span>'
    end
    it "should return nil when the member's full name is not set" do
      @member.full_name = ''
      helper.member_profile_full_name(@member).should == nil
    end
  end

  describe "#member_profile_location(member)" do
    before do
      @member = Member.new(:city => "Boston", :country => "United States")
    end
    it "should return the member's location along with a map marker icon" do
      helper.member_profile_location(@member).should == '<p><i class="icon-map-marker"></i> Boston, United States</p>'
    end
    it "should return nil when the member's location is not set" do
      @member.city = ""
      @member.country = ""
      helper.member_profile_location(@member).should == nil
    end
  end
end
