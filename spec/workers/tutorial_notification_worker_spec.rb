require 'spec_helper'

describe TutorialNotificationWorker do
  
  describe "#perform(tutorial_id)" do
    before(:each) do
      @member_1 = double(Member)
      @tutorial_id = 123
      @tutorial = double(Tutorial, :title => "Creating a Sampled Bass Patch", :description => "How 2 make 1", :member => @member_1)
      Tutorial.stub(:find).and_return(@tutorial)

      @member_2 = double(Member, :name => "DJ Jones")
      Member.stub(:all).and_return(double('all members', :find_each => nil))

      @email = double('email', :deliver => true)
      NotificationMailer.stub(:tutorial_notification).and_return(@email)
    end
    it "should find the Tutorial from tutorial_id" do
      Tutorial.should_receive(:find).with(@tutorial_id).and_return(@tutorial)
      TutorialNotificationWorker.new.perform(@tutorial_id)
    end
    it "should deliver a tutorial notification to all members except the member who created the tutorial" do
      Member.all.should_receive(:find_each).and_yield(@member_1).and_yield(@member_2)
      NotificationMailer.should_receive(:tutorial_notification).once.with(:member => @member_2, :tutorial => @tutorial).and_return(@email)
      @email.should_receive(:deliver).once
      TutorialNotificationWorker.new.perform(@tutorial_id)
    end
    it "should have an async method" do
      TutorialNotificationWorker.should respond_to(:perform_async)
    end
  end
end
