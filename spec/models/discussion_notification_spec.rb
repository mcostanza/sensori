require 'spec_helper'

describe DiscussionNotification do
  before do
    @discussion_notification = FactoryGirl.build(:discussion_notification)
  end

  describe "validations" do
    it "should be valid give valid attributes" do
      @discussion_notification.should be_valid
    end
    it "should be invalid without a member" do
      @discussion_notification.member = nil
      @discussion_notification.should_not be_valid
    end
    it "should be invalid without a discussion" do
      @discussion_notification.discussion = nil
      @discussion_notification.should_not be_valid
    end
  end
end
