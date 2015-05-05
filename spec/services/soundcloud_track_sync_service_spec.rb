require 'spec_helper'

describe SoundcloudTrackSyncService do

  let(:service) { described_class.new }

  describe "#run" do
    let(:member) { build(:member) }

    before(:each) do
      allow(member).to receive(:sync_soundcloud_tracks)
      allow(Member).to receive(:find_each).and_yield(member)
    end

    it "finds members in batches" do
      Member.should_receive(:find_each)
      service.run
    end

    it "syncs each Member's soundcloud tracks" do
      expect(member).to receive(:sync_soundcloud_tracks)
      service.run
    end 
  end
end
