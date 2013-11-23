require 'spec_helper'

describe SessionNotificationWorker do
  
  describe "#perform(session_id)" do
    before(:each) do
      @member_1 = double(Member)
      @session_id = 123
      @session = double(Session, :title => "Creating a Sampled Bass Patch", :description => "How 2 make 1", :member => @member_1)
      Session.stub(:find).and_return(@session)

      @member_2 = double(Member, :name => "DJ Jones")
      Member.stub(:find_each).and_yield(@member_1).and_yield(@member_2)

      @email = double('email', :deliver => true)
      NotificationMailer.stub(:session_notification).and_return(@email)
    end
    it "should find the Session from session_id" do
      Session.should_receive(:find).with(@session_id).and_return(@session)
      SessionNotificationWorker.new.perform(@session_id)
    end
    it "should deliver a session notification to all members except the member who created the session" do
      Member.should_receive(:find_each).and_yield(@member_1).and_yield(@member_2)
      NotificationMailer.should_receive(:session_notification).once.with(:member => @member_2, :session => @session).and_return(@email)
      @email.should_receive(:deliver).once
      SessionNotificationWorker.new.perform(@session_id)
    end
    it "should have an async method" do
      SessionNotificationWorker.should respond_to(:perform_async)
    end
  end
end
