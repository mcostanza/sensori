require 'spec_helper'

describe Tutorial do
  before(:each) do
    @tutorial = FactoryGirl.build(:tutorial)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @tutorial.should be_valid
    end
    it "should be invalid without a title" do
      @tutorial.title = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without a description" do
      @tutorial.description = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without a member" do
      @tutorial.member = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without a body" do
      @tutorial.body = nil
      @tutorial.should_not be_valid
    end
  end

  it "should set slug from the title when saving" do
    @tutorial.save
    @tutorial.slug.should == @tutorial.title.parameterize
  end
end
