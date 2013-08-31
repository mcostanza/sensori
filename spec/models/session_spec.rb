require 'spec_helper'

describe Session do
  before(:each) do
    @session = FactoryGirl.build(:session)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @session.should be_valid
    end
    it "should be invalid without a member" do
      @session.member = nil
      @session.should_not be_valid
    end
    it "should be invalid without a title" do
      @session.title = nil
      @session.should_not be_valid
    end
    it "should be invalid without a description" do
      @session.description = nil
      @session.should_not be_valid
    end
    it "should be invalid without a image" do
      @session.remove_image!
      @session.should_not be_valid
    end
    it "should be invalid without an end_date" do
      @session.end_date = nil
      @session.should_not be_valid 
    end
  end

  describe "associations" do
    it "should have a member association" do
      @session.should respond_to(:member)
    end
    it "should have a submissions association" do
      @session.should respond_to(:submissions)
    end
  end
  
  it "should set a slug from the title when saving" do
    @session.slug.should be_nil
    @session.save
    @session.slug.should == @session.title.parameterize
  end
end
