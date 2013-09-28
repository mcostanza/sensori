require 'spec_helper'

describe DiscussionNotificationWorker do
  
  describe "#perform(response_id)" do
    before(:each) do
      @response_id = 1
      @member = double(Member)
      @notifications = [double(DiscussionNotification, :member => @member)]
      @discussion = double(Discussion, :notifications => @notifications)
      @response = double(Response, :discussion => @discussion, :member => double(Member))
      Response.stub(:find).and_return(@response)
      @email = double('email', :deliver => true)
      NotificationMailer.stub(:discussion_notification).and_return(@email)
    end
    it "should find the Response from response_id" do
      Response.should_receive(:find).with(@response_id).and_return(@response)
      DiscussionNotificationWorker.new.perform(@response_id)
    end
    it "should deliver the notifications" do
      NotificationMailer.should_receive(:discussion_notification).with(:member => @member, :response => @response).and_return(@email)
      @email.should_receive(:deliver)
      DiscussionNotificationWorker.new.perform(@response_id)
    end
    it "should not send a notification to the member responding" do
      @response.stub(:member).and_return(@member)
      NotificationMailer.should_not_receive(:discussion_notification)
      DiscussionNotificationWorker.new.perform(@response_id)
    end
    it "should have an async method" do
      DiscussionNotificationWorker.should respond_to(:perform_async)
    end
  end
end
