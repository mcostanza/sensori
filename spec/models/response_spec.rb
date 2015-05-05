require 'spec_helper'

describe Response do
  let(:response) { build(:response) }
  
  context "validations" do
    it "is valid given valid attributes" do
      expect(response).to be_valid
    end
    it "is invalid without a discussion" do
      response.discussion = nil
      expect(response).not_to be_valid
    end
    it "is invalid without a body" do
      response.body = nil
      expect(response).not_to be_valid
    end
    it "is invalid without a member" do
      response.member = nil
      expect(response).not_to be_valid
    end
  end

  context "associations" do
    it "belongs to a discussion" do
      expect(Response.reflect_on_association(:discussion).macro).to eq :belongs_to
    end
    it "belongs to a member" do
      expect(Response.reflect_on_association(:member).macro).to eq :belongs_to
    end
  end

  context "callbacks" do
    context "on create" do
      before do
        allow(DiscussionNotificationWorker).to receive(:perform_async)
      end

      it "creates a worker to deliver the notifications" do
        response.save
        expect(DiscussionNotificationWorker).to have_received(:perform_async).with(response.reload.id)
      end
    
      it "finds/creates a discussion notification for the member responding" do
        expect {
          response.save
        }.to change {
          DiscussionNotification.where(member_id: response.member_id, discussion_id: response.discussion_id).count
        }.by(1)
      end

      it "updates the discussion with an incremented response_count and last_post_at set to self.created_at" do
        expect {
          response.save
        }.to change {
          response.discussion.response_count
        }.from(0).to(1)
        
        expect(response.discussion.last_post_at).to eq response.created_at
      end
    end
  end

  it "stores an html version of the body text when set" do
    expect(Response.new(:body => 'test').body_html).to be_present
  end
end
