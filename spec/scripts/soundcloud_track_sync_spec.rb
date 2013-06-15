require 'spec_helper'

describe SoundcloudTrackSync do

  before(:each) do
    @script = SoundcloudTrackSync
  end

  describe ".run" do
    before(:each) do
      @member = mock(Member, :sync_soundcloud_tracks => true)
      Member.stub!(:find_each).and_yield(@member)
    end
    it "should batch find each Member" do
      Member.should_receive(:find_each)
      @script.run
    end
    it "should sync each Member's soundcloud tracks" do
      @member.should_receive(:sync_soundcloud_tracks)
      @script.run
    end 
  end
end