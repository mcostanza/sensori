require 'spec_helper'

describe MemberTrackSyncWorker do
  
  describe "#perform(member_id)" do
    let(:member) { create(:member) }

    before(:each) do
      allow(member).to receive(:sync_soundcloud_tracks)
      allow(Member).to receive(:find).and_return(member)
    end

    it "finds the Member from member_id" do
      expect(Member).to receive(:find).with(member.id).and_return(member)
      MemberTrackSyncWorker.new.perform(member.id)
    end

    it "syncs the Member's soundcloud tracks" do
      expect(member).to receive(:sync_soundcloud_tracks)
      MemberTrackSyncWorker.new.perform(member.id)
    end

    it "has an async method" do
      expect(MemberTrackSyncWorker).to respond_to(:perform_async)
    end
  end

end
