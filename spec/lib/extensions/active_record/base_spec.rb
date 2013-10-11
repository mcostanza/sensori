require 'spec_helper'

describe ActiveRecord::Base do
  before(:each) do
    @member = FactoryGirl.build(:member)
  end

  describe "#just_created?" do
    it "should return true when a record is just created" do
      @member.save
      @member.just_created?.should == true
    end
    it "should return false when a record already existed" do
      @member.save
      member = Member.find(@member.id)
      member.just_created?.should == false
    end
  end
end
