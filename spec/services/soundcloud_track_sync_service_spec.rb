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
      expect(Member).to receive(:find_each)
      service.run
    end

    it "syncs each Member's soundcloud tracks" do
      expect(member).to receive(:sync_soundcloud_tracks)
      service.run
    end 

    context 'when syncing raises an error' do
      let(:member_2) { build(:member) }
      let(:soundcloud_error) { SoundCloud::ResponseError.new(Hashie::Mash.new(code: 400)) }

      before do
        allow(Member).to receive(:find_each).and_yield(member).and_yield(member_2)
      end

      it 'continues syncing for other members and raises a single error afterward' do
        expect(member).to receive(:sync_soundcloud_tracks).and_raise(soundcloud_error)
        expect(member_2).to receive(:sync_soundcloud_tracks)
        expect {
          service.run
        }.to raise_error
      end
    end
  end
end
