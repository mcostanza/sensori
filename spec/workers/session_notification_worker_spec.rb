require 'spec_helper'

describe SessionNotificationWorker do
  
  describe "#perform(session_id)" do
    let(:member_1) { create(:member) }
    let(:member_2) { create(:member) }
    let(:member_3) { create(:member, :email => nil) }
    let(:session) { create(:session, :member => member_1) }

    let(:email) { double('email') }

    before(:each) do
      allow(email).to receive(:deliver)
      allow(NotificationMailer).to receive(:session_notification).and_return(email)
    end

    it "finds the Session from session_id" do
      expect(Session).to receive(:find).with(session.id).and_return(session)
      SessionNotificationWorker.new.perform(session.id)
    end

    it "delivers a session notification to all members with an email, except the member who created the session" do
      expect(NotificationMailer).to receive(:session_notification).once.with(:member => member_2, :session => session).and_return(email)
      expect(email).to receive(:deliver).once
      SessionNotificationWorker.new.perform(session.id)
    end

    it "has an async method" do
      expect(SessionNotificationWorker).to respond_to(:perform_async)
    end
  end
end
