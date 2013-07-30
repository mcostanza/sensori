require 'spec_helper'

describe DiscussionNotificationWorker do
  
  describe "#perform(member_id)" do
    before(:each) do
      @response_id = 1
      @member = mock(Member)
      @notifications = [mock(DiscussionNotification, :member => @member)]
      @discussion = mock(Discussion, :notifications => @notifications)
      @response = mock(Response, :discussion => @discussion)
      Response.stub!(:find).and_return(@response)
      DiscussionNotificationMailer.stub!(:deliver)
    end
    it "should find the Response from response_id" do
      Response.should_receive(:find).with(@response_id).and_return(@response)
      DiscussionNotificationWorker.new.perform(@response_id)
    end
    it "should deliver the notifications" do
      DiscussionNotificationMailer.should_receive(:deliver).with(@member, @response)
      DiscussionNotificationWorker.new.perform(@member_id)
    end
    it "should have an async method" do
      DiscussionNotificationWorker.should respond_to(:perform_async)
    end
  end
end
