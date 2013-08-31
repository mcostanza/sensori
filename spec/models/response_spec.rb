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
      it "should call setup_discussion_notification" do
        @response.should_receive(:setup_discussion_notification)
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

  describe "#setup_discussion_notification" do
    it "should find or create a discussion notification for the member responding" do
      DiscussionNotification.should_receive(:find_or_create_by_member_id_and_discussion_id).with({
        :member_id => @response.member_id,
        :discussion_id => @response.discussion_id
      })
      @response.setup_discussion_notification
    end
  end
end
