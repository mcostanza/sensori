require 'spec_helper'

describe Response do
  before(:each) do
    @response = FactoryGirl.build(:response)
  end

  describe "validation" do
    it "should be valid given valid attributes" do
      @response.should be_valid
    end
    it "should be invalid without a discussion" do
      @response.discussion = nil
      @response.should_not be_valid
    end
    it "should be invalid without a body" do
      @response.body = nil
      @response.should_not be_valid
    end
    it "should be invalid without a member" do
      @response.member = nil
      @response.should_not be_valid
    end
  end

  describe "association" do
    it "should have a discussion" do
      @response.should respond_to(:discussion)
    end
    it "should have a member" do
      @response.should respond_to(:member)
    end
  end

  describe "callbacks" do
    describe "after_create" do
      it "should call deliver_discussion_notifications" do
        @response.should_receive(:deliver_discussion_notifications)
        @response.save
      end
    end
  end

  it "should store an html version of the body text when set" do
    @response = Response.new(:body => 'test')
    @response.body_html.should_not be_blank
  end

  describe "#deliver_discussion_notifications" do
    it "should create a worker to deliver the notifications" do
      DiscussionNotificationWorker.should_receive(:perform_async).with(@response.id)
      @response.deliver_discussion_notifications
    end
  end
end
