require 'spec_helper'

describe Member do
  before(:each) do
    @member = FactoryGirl.build(:member)
  end
  
  describe "validations" do
    it "should be valid given valid attributes" do
      @member.valid?.should be_true
    end
    it "should be invalid without a soundcloud_id" do
      @member.soundcloud_id = nil
      @member.valid?.should be_false
    end
    it "should be invalid with a non-unique soundcloud_id" do
      @member.save
      other = FactoryGirl.build(:member)
      other.soundcloud_id = @member.soundcloud_id
      other.valid?.should be_false
    end
    it "should be invalid without name" do
      @member.name = nil
      @member.valid?.should be_false
    end
    it "should be invalid without slug" do
      @member.slug = nil
      @member.valid?.should be_false
    end
    it "should be invalid without image_url" do
      @member.image_url = nil
      @member.valid?.should be_false
    end
    it "should be invalid without soundcloud_access_token" do
      @member.soundcloud_access_token = nil
      @member.valid?.should be_false
    end
  end

  describe "associations" do
    it "should have a tracks association" do
      @member.should respond_to(:tracks)
    end
  end

  describe "#soundcloud_tracks(reload = false)" do
    before(:each) do
      @track = Hashie::Mash.new(:id => 123)
      @app_client = mock(::Soundcloud, :get => [@track])
      Sensori::Soundcloud.stub!(:app_client).and_return(@app_client)
    end
    it "should load the member's tracks from the Soundcloud API" do
      @app_client.should_receive(:get).with("/users/#{@member.soundcloud_id}/tracks").and_return([@track])
      @member.soundcloud_tracks.should == [@track]
    end
    it "should be memoized" do
      @app_client.should_receive(:get).once.and_return([@track])
      @member.soundcloud_tracks
      @member.soundcloud_tracks
    end
    it "should reload if the reload parameter is passed" do
      @member.soundcloud_tracks = 'tracks!'
      @app_client.should_receive(:get).with("/users/#{@member.soundcloud_id}/tracks").and_return([@track])
      @member.soundcloud_tracks(:reload).should == [@track]      
    end
  end

  describe "#sync_soundcloud_tracks" do
    before(:each) do
      @soundcloud_track = Hashie::Mash.new({
        "kind"=>"track", 
        "id"=>96520157, 
        "created_at"=>"2013/06/12 04:57:28 +0000", 
        "user_id"=>3897419, 
        "duration"=>116125, 
        "commentable"=>true, 
        "state"=>"finished", 
        "original_content_size"=>20470244, 
        "sharing"=>"public", 
        "tag_list"=>"beats hip-hop costanza instrumental", 
        "permalink"=>"restless", 
        "streamable"=>true, 
        "embeddable_by"=>"all", 
        "downloadable"=>false, 
        "purchase_url"=>nil, 
        "label_id"=>nil, 
        "purchase_title"=>nil, 
        "genre"=>"Beats", 
        "title"=>"Restless", 
        "description"=>"Completed 2013-06-11", 
        "label_name"=>"", 
        "release"=>"", 
        "track_type"=>"original", 
        "key_signature"=>"", 
        "isrc"=>"", 
        "video_url"=>nil, 
        "bpm"=>nil, 
        "release_year"=>nil, 
        "release_month"=>nil, 
        "release_day"=>nil, 
        "original_format"=>"wav", 
        "license"=>"all-rights-reserved", 
        "uri"=>"http://api.soundcloud.com/tracks/96520157", 
        "user"=>{
          "id"=>3897419, 
          "kind"=>"user", 
          "permalink"=>"dj-costanza", 
          "username"=>"DJ Costanza", 
          "uri"=>"http://api.soundcloud.com/users/3897419", 
          "permalink_url"=>"http://soundcloud.com/dj-costanza", 
          "avatar_url"=>"http://i1.sndcdn.com/avatars-000039096498-86ivun-large.jpg?0c5f27c"
        }, 
        "permalink_url"=>"http://soundcloud.com/dj-costanza/restless", 
        "artwork_url"=>"http://i1.sndcdn.com/artworks-000050386537-zjgsyi-large.jpg?0c5f27c", 
        "waveform_url"=>"http://w1.sndcdn.com/3Vu1z6awKyQs_m.png", 
        "stream_url"=>"http://api.soundcloud.com/tracks/96520157/stream", 
        "playback_count"=>19, 
        "download_count"=>0, 
        "favoritings_count"=>5, 
        "comment_count"=>1, 
        "attachments_uri"=>"http://api.soundcloud.com/tracks/96520157/attachments"
      })
      @member.stub!(:soundcloud_tracks).and_return([@soundcloud_track])

      @track = mock(Track, :update_attributes => true)
      @member.tracks.stub!(:find_or_initialize_by_soundcloud_id).and_return(@track)
    end
    it "should load the member's soundcloud tracks" do
      @member.should_receive(:soundcloud_tracks).with(:reload).and_return([@soundcloud_track])
      @member.sync_soundcloud_tracks
    end
    describe "for each soundcloud track" do
      it "should find or initialize a Track based on the soundcloud_id" do
        @member.tracks.should_receive(:find_or_initialize_by_soundcloud_id).with(@soundcloud_track.id).and_return(@track)
        @member.sync_soundcloud_tracks 
      end
      it "should update the Track attributes from soundcloud track data" do
        expected_attributes = {
          :title => @soundcloud_track.title,
          :permalink_url => @soundcloud_track.permalink_url,
          :artwork_url => @soundcloud_track.artwork_url,
          :stream_url => @soundcloud_track.stream_url,
          :posted_at => Time.parse(@soundcloud_track.created_at)
        }
        @track.should_receive(:update_attributes).with(expected_attributes)
        @member.sync_soundcloud_tracks 
      end
      it "should set the Track's artwork_url to the Member's image_url if no artwork_url is given in the response" do
        @soundcloud_track.artwork_url = nil
        @track.should_receive(:update_attributes).with(hash_including(:artwork_url => @member.image_url))
        @member.sync_soundcloud_tracks 
      end
    end
  end

  describe ".sync_from_soundcloud(access_token)" do
    before(:each) do
      @access_token = 'soundtokez'

      @member_profile = ::Soundcloud::HashResponseWrapper.new({
        "id" => 3897419, 
        "permalink" => "dj-costanza", 
        "username" => "DJ Costanza", 
        "uri" => "https://api.soundcloud.com/users/3897419", 
        "permalink_url" => "http://soundcloud.com/dj-costanza", 
        "avatar_url" => "https://i1.sndcdn.com/avatars-000039096498-86ivun-large.jpg?0c5f27c"
      })
      @soundcloud_client = mock(::Soundcloud, :get => @member_profile)
      ::Soundcloud.stub!(:new).and_return(@soundcloud_client)

      @member = mock(Member, :save => true, :valid? => true, :soundcloud_id => @member_profile.soundcloud_id)
      Member.stub!(:find_or_initialize_by_soundcloud_id).and_return(@member)
    end
    describe "access token is present" do
      it "should load the soundcloud user's profile" do
        ::Soundcloud.should_receive(:new).with(:access_token => @access_token).and_return(@soundcloud_client)
        @soundcloud_client.should_receive(:get).with('/me').and_return(@member_profile)
        Member.sync_from_soundcloud(@access_token)
      end
      it "should find or initialize a Member from soundcloud profile data" do
        expected_attributes = {
          :soundcloud_id => @member_profile.id,
          :name => @member_profile.username,
          :slug => @member_profile.permalink,
          :image_url => "https://i1.sndcdn.com/avatars-000039096498-86ivun-t500x500.jpg?0c5f27c",
          :soundcloud_access_token => @access_token
        }
        Member.should_receive(:find_or_initialize_by_soundcloud_id).with(expected_attributes).and_return(@member)
        Member.sync_from_soundcloud(@access_token)
      end
      it "should attempt to save the Member" do
        @member.should_receive(:save)
        Member.sync_from_soundcloud(@access_token)
      end
      it "should return the Member" do
        Member.sync_from_soundcloud(@access_token).should == @member
      end
    end
    describe "access_token is nil" do
      it "should return without loading any data" do
        ::Soundcloud.should_not_receive(:new)
        Member.should_not_receive(:find_or_initialize_by_soundcloud_id)
        Member.sync_from_soundcloud(nil).should be_nil
      end
    end
  end

end
