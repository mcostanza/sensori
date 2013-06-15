require 'spec_helper'

describe Track do
  before(:each) do
    @track = FactoryGirl.build(:track)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @track.should be_valid
    end
    it "should be invalid without a member" do
      @track.member = nil
      @track.should_not be_valid
    end
    it "should be invalid without a soundcloud_id" do
      @track.soundcloud_id = nil
      @track.should_not be_valid
    end
    it "should be invalid with a non-unique soundcloud_id" do
      @track.save
      other_track = FactoryGirl.build(:track, :soundcloud_id => @track.soundcloud_id)
      other_track.should_not be_valid
    end
    it "should be invalid without a title" do
      @track.title = nil
      @track.should_not be_valid
    end
    it "should be invalid without a permalink_url" do
      @track.permalink_url = nil
      @track.should_not be_valid
    end
    it "should be invalid without a non-unique permalink_url" do
      @track.save
      other_track = FactoryGirl.build(:track, :permalink_url => @track.permalink_url)
      other_track.should_not be_valid
    end
    it "should be invalid without posted_at" do
      @track.posted_at = nil
      @track.should_not be_valid
    end
    it "should be invalid without an artwork_url" do
      @track.artwork_url = nil
      @track.should_not be_valid
    end
  end

  describe "associations" do
    it "should have a member association" do
      @track.should respond_to(:member)
    end
  end

  describe "scopes" do
    describe ".latest(limit)" do
      it "should return the specified number of Tracks, ordered by posted_at DESC" do
        @track.posted_at = 1.hour.ago
        track_2 = FactoryGirl.create(:track, :posted_at => 5.minutes.ago)
        track_3 = FactoryGirl.create(:track, :posted_at => 30.minutes.ago)
        Track.latest(2).should == [track_2, track_3]       
      end
    end
  end
end
