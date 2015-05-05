require 'spec_helper'

describe DiscussionNotification do
  let(:discussion_notification) { build(:discussion_notification) }
  
  describe "validations" do
    it "is valid when given valid attributes" do
      expect(discussion_notification).to be_valid
    end
    it "is invalid without a member" do
      discussion_notification.member = nil
      expect(discussion_notification).not_to be_valid
    end
    it "is invalid without a discussion" do
      discussion_notification.discussion = nil
      expect(discussion_notification).not_to be_valid
    end
  end
end
