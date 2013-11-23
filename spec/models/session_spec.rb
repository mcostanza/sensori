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
  
  describe "callbacks" do
    it "should set a slug from the title when saving" do
      @session.slug.should be_nil
      @session.save
      @session.slug.should == @session.title.parameterize
    end
    it "should call deliver_session_notifications after create" do
      @session.should_receive(:deliver_session_notifications)
      @session.save
    end
  end

  describe "#deliver_session_notifications" do
    it "should create a worker to deliver the notifications" do
      @session.id = 123
      SessionNotificationWorker.should_receive(:perform_async).with(@session.id)
      @session.deliver_session_notifications
    end
  end
end
