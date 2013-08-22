require 'spec_helper'

describe MemberTrackSyncWorker do
  
  describe "#perform(member_id)" do
    before(:each) do
      @member_id = 1
      @member = double(Member, :sync_soundcloud_tracks => true)
      Member.stub(:find).and_return(@member)
    end
    it "should find the Member from member_id" do
      Member.should_receive(:find).with(@member_id).and_return(@member)
      MemberTrackSyncWorker.new.perform(@member_id)
    end
    it "should sync the Member's soundcloud tracks" do
      @member.should_receive(:sync_soundcloud_tracks)
      MemberTrackSyncWorker.new.perform(@member_id)
    end
    it "should have an async method" do
      MemberTrackSyncWorker.should respond_to(:perform_async)
    end
  end

end
