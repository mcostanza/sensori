require 'spec_helper'

describe TutorialNotificationWorker do
  
  describe "#perform(tutorial_id)" do
    let(:member_1) { create(:member) }
    let(:member_2) { create(:member) }
    let(:member_3) { create(:member, :email => nil) }
    let(:tutorial) { create(:tutorial, :member => member_1) }

    let(:email) { double('email') }

    before(:each) do
      allow(email).to receive(:deliver)
      allow(NotificationMailer).to receive(:tutorial_notification).and_return(email)
    end

    it "finds the Tutorial from tutorial_id" do
      expect(Tutorial).to receive(:find).with(tutorial.id).and_return(tutorial)
      TutorialNotificationWorker.new.perform(tutorial.id)
    end

    it "delivers a tutorial notification to all members with an email, except the member who created the tutorial" do
      expect(NotificationMailer).to receive(:tutorial_notification).once.with(:member => member_2, :tutorial => tutorial).and_return(email)
      expect(email).to receive(:deliver).once
      TutorialNotificationWorker.new.perform(tutorial.id)
    end

    it "has an async method" do
      expect(TutorialNotificationWorker).to respond_to(:perform_async)
    end
  end
end
