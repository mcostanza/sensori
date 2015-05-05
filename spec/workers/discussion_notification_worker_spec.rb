require 'spec_helper'

describe DiscussionNotificationWorker do
  
  describe "#perform(response_id)" do
    let(:discussion) { create(:discussion) }
    let!(:response_1) { create(:response, discussion: discussion) }
    let!(:response_2) { create(:response, discussion: discussion) }
    let!(:response_3) { create(:response, discussion: discussion) }
    let(:email ) { double('email') }

    before(:each) do
      allow(email).to receive(:deliver)
      allow(NotificationMailer).to receive(:discussion_notification).and_return(email)
    end

    it "finds the Response from response_id" do
      expect(Response).to receive(:find).with(response_3.id).and_return(response_3)
      DiscussionNotificationWorker.new.perform(response_3.id)
    end

    it "sends an email to each member associated with the discussion" do
      expect(NotificationMailer).to receive(:discussion_notification).with(:member => response_1.member, :response => response_3).and_return(email)
      expect(NotificationMailer).to receive(:discussion_notification).with(:member => response_2.member, :response => response_3).and_return(email)
      expect(email).to receive(:deliver)
      DiscussionNotificationWorker.new.perform(response_3.id)
    end
    
    it "does not send a notification to the responding member" do
      expect(NotificationMailer).not_to receive(:discussion_notification).with(:member => response_3.member, :response => response_3)
      DiscussionNotificationWorker.new.perform(response_3.id)
    end

    it "has an async method" do
      expect(DiscussionNotificationWorker).to respond_to(:perform_async)
    end
  end
end
