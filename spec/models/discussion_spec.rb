require 'spec_helper'

describe Discussion do
  before(:each) do
    @discussion = FactoryGirl.build(:discussion)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @discussion.should be_valid
    end
    it "should be invalid without a member" do
      @discussion.member = nil
      @discussion.should_not be_valid
    end
    it "should be invalid without a subject" do
      @discussion.subject = ' '
      @discussion.should_not be_valid
    end
    it "should be invalid without a body" do
      @discussion.body = ' '
      @discussion.should_not be_valid
    end
  end

  describe "associations" do
    it "should have a member association" do
      @discussion.should respond_to(:member)
    end
    it "should have a responses association" do
      @discussion.should respond_to(:responses)
    end
  end

  it "should set slug from the subject when saving" do
    @discussion.slug.should be_nil
    @discussion.save
    @discussion.slug.should == @discussion.subject.parameterize
  end
  
  it "should store an html version of the body text when set" do
    @discussion = Discussion.new(:body => 'test')
    @discussion.body_html.should_not be_blank
  end
end
