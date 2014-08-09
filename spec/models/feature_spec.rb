require 'spec_helper'

describe Feature do
  before(:each) do
    @feature = FactoryGirl.build(:feature)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @feature.should be_valid
    end
    it "should be invalid without a member" do
      @feature.member = nil
      @feature.should_not be_valid
    end
    it "should be invalid without a title" do
      @feature.title = nil
      @feature.should_not be_valid
    end
    it "should be invalid without a description" do
      @feature.description = nil
      @feature.should_not be_valid
    end
    it "should be invalid without an image" do
      @feature.remove_image!
      @feature.should_not be_valid
    end
    it "should be invalid without a link" do
      @feature.link = nil
      @feature.should_not be_valid
    end
  end

  describe "associations" do
    it "should have a member association" do
      @feature.should respond_to(:member)
    end
  end
end
