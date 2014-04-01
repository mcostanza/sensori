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

  describe "#active?" do
    before do
      @current_time = Time.parse('2014-05-05 23:59:59')
      @now = double("time", :in_time_zone => @current_time)
      Time.stub(:now).and_return(@now)
    end
    it "should compare against the current time in PST" do
      @now.should_receive(:in_time_zone).with("Pacific Time (US & Canada)").and_return(@current_time)
      @session.end_date = Time.parse('2014-05-06 00:00:00')
      @session.active?
    end
    it "should return false when the end date is in the past" do
      @session.end_date = Time.parse('2014-05-04 00:00:00')
      @session.active?.should  be_false
    end
    it "should return true when the end date is in the future" do
      @session.end_date = Time.parse('2014-05-06 00:00:00')
      @session.active?.should be_true
    end
    it "should return true when the end date is today" do
      @session.end_date = Time.parse('2014-05-05 00:00:00')
      @session.active?.should be_true
    end
    it "should return false when end_date isn't set" do
      @session.end_date = nil
      @session.active?.should be_false
    end
  end
end
