require 'spec_helper'

describe Member do
  let(:member) { build(:member) }

  let(:soundcloud_track) do
    Hashie::Mash.new({
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
  end

  let(:member_profile) do
    ::Soundcloud::HashResponseWrapper.new({
      "id" => 3897419, 
      "permalink" => "dj-costanza", 
      "username" => "DJ Costanza", 
      "uri" => "https://api.soundcloud.com/users/3897419", 
      "permalink_url" => "http://soundcloud.com/dj-costanza", 
      "avatar_url" => "https://i1.sndcdn.com/avatars-000039096498-86ivun-large.jpg?0c5f27c",
      "full_name" => "Mike Costanza",
      "description" => "Beat Buddy",
      "city" => "San Diego",
      "country" => "United States"
    })
  end  

  describe "validations" do
    it "is valid given valid attributes" do
      expect(member).to be_valid
    end
    it "is invalid without a soundcloud_id" do
      member.soundcloud_id = nil
      expect(member).not_to be_valid
    end
    it "is invalid with a non-unique soundcloud_id" do
      member.save
      other = build(:member, soundcloud_id: member.soundcloud_id)
      expect(other).not_to be_valid
    end
    it "is invalid without name" do
      member.name = nil
      expect(member).not_to be_valid
    end
    it "is invalid without slug" do
      member.slug = nil
      expect(member).not_to be_valid
    end
    it "is invalid without image_url" do
      member.image_url = nil
      expect(member).not_to be_valid
    end
    it "is invalid without soundcloud_access_token" do
      member.soundcloud_access_token = nil
      expect(member).not_to be_valid
    end
  end

  describe "associations" do
    it "has many tracks" do
      expect(Member.reflect_on_association(:tracks).macro).to eq :has_many
    end
    it "has many tutorials" do
      expect(Member.reflect_on_association(:tutorials).macro).to eq :has_many
    end
    it "has many submissions" do
      expect(Member.reflect_on_association(:submissions).macro).to eq :has_many
    end
  end

  describe "callbacks" do
    context "after_create" do
      before do
        MemberTrackSyncWorker.jobs.clear
      end

      it "syncs soundcloud tracks in the background" do
        expect {
          member.save
        }.to change {
          MemberTrackSyncWorker.jobs.size
        }.by(1)
        
        expect(MemberTrackSyncWorker.jobs.first["args"]).to eq [member.id]
      end
    end
  end

  describe "#soundcloud_tracks(reload = false)" do
    let(:app_client) { double(::Soundcloud) }

    before(:each) do
      allow(app_client).to receive(:get).and_return([soundcloud_track])
      allow(Sensori::Soundcloud).to receive(:app_client).and_return(app_client)
    end

    it "loads and returns the member's tracks from the Soundcloud API" do
      expect(app_client).to receive(:get).with("/users/#{member.soundcloud_id}/tracks").and_return([soundcloud_track])
      expect(member.soundcloud_tracks).to eq [soundcloud_track]
    end

    it "is memoized" do
      expect(app_client).to receive(:get).once.and_return([soundcloud_track])
      member.soundcloud_tracks
      member.soundcloud_tracks
    end

    context 'when reload is passed as a truthy value' do
      before do
        member.soundcloud_tracks = 'tracks!'      
      end

      it "reloads data from the Soundcloud API" do
        expect(app_client).to receive(:get).with("/users/#{member.soundcloud_id}/tracks").and_return([soundcloud_track])
        expect(member.soundcloud_tracks(:reload)).to eq [soundcloud_track]      
      end  
    end
  end

  describe "#sync_soundcloud_tracks" do
    let(:member) { create(:member) }

    let(:full_size_artwork_url) { "http://i1.sndcdn.com/artworks-000050386537-zjgsyi-t500x500.jpg?0c5f27c" }

    before do
      allow(member).to receive(:soundcloud_tracks).and_return([soundcloud_track])
    end

    it "loads the member's soundcloud tracks" do
      expect(member).to receive(:soundcloud_tracks).with(:reload).and_return([soundcloud_track])
      member.sync_soundcloud_tracks
    end

    context "each soundcloud track" do
      context "when there is an existing Track model" do
        let!(:existing_track) { create(:track, member: member, soundcloud_id: soundcloud_track.id) }

        it "updates the Track" do
          expect {
            member.sync_soundcloud_tracks
          }.not_to change { 
            member.tracks.count
          }

          existing_track.reload

          expect(existing_track.soundcloud_id).to eq soundcloud_track.id
          expect(existing_track.title).to eq soundcloud_track.title
          expect(existing_track.permalink_url).to eq soundcloud_track.permalink_url
          expect(existing_track.artwork_url).to eq full_size_artwork_url
          expect(existing_track.stream_url).to eq soundcloud_track.stream_url
          expect(existing_track.posted_at).to eq soundcloud_track.created_at
        end      
      end

      context "when there is no existing Track model" do
        it "creates a Track" do
          expect {
            member.sync_soundcloud_tracks
          }.to change { 
            member.tracks.count
          }.by(1)

          track = member.tracks.last
          expect(track.soundcloud_id).to eq soundcloud_track.id
          expect(track.title).to eq soundcloud_track.title
          expect(track.permalink_url).to eq soundcloud_track.permalink_url
          expect(track.artwork_url).to eq full_size_artwork_url
          expect(track.stream_url).to eq soundcloud_track.stream_url
          expect(track.posted_at).to eq soundcloud_track.created_at
        end
      end

      context 'when there is no artwork_url' do
        before do
          soundcloud_track.artwork_url = nil
        end

        it "sets the Track's artwork_url to the Member's image_url" do
          member.sync_soundcloud_tracks 
          expect(member.tracks.last.artwork_url).to eq member.image_url
        end
      end
      
      context 'when tracks were deleted from Soundcloud' do
        let!(:track) { create(:track, member: member) }

        it "destroys the Track models" do
          member.sync_soundcloud_tracks
          
          expect { 
            track.reload 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end  
      end
      
      context "when Soundcloud's API returns no tracks" do
        let!(:track) { create(:track, member: member) }

        before do
          allow(member).to receive(:soundcloud_tracks).and_return([])
        end

        it "does not destroy tracks as a safeguard" do
          member.sync_soundcloud_tracks

          expect {
            track.reload
          }.not_to raise_error
        end
      end
    end
  end

  describe ".sync_from_soundcloud(access_token)" do
    let(:access_token) { 'soundtokez' }

    let(:soundcloud_client) { double(::Soundcloud) }

    before(:each) do
      allow(soundcloud_client).to receive(:get).and_return(member_profile)
      allow(::Soundcloud).to receive(:new).and_return(soundcloud_client)
    end

    context "when access token is present" do
      it "loads the soundcloud user's profile" do
        expect(::Soundcloud).to receive(:new).with(:access_token => access_token).and_return(soundcloud_client)
        expect(soundcloud_client).to receive(:get).with('/me').and_return(member_profile)
        Member.sync_from_soundcloud(access_token)
      end

      it "creates a Member from Soundcloud profile data" do
        expect {
          Member.sync_from_soundcloud(access_token)
        }.to change { 
          Member.count
        }.by(1)

        member = Member.last

        expect(member.soundcloud_id).to eq member_profile.id
        expect(member.name).to eq member_profile.username
        expect(member.slug).to eq member_profile.permalink
        expect(member.image_url).to eq "https://i1.sndcdn.com/avatars-000039096498-86ivun-t500x500.jpg?0c5f27c"
        expect(member.full_name).to eq member_profile.full_name
        expect(member.bio).to eq member_profile.description
        expect(member.city).to eq member_profile.city
        expect(member.country).to eq member_profile.country
        expect(member.soundcloud_access_token).to eq access_token
      end
      
      it "returns the Member" do
        expect(Member.sync_from_soundcloud(access_token)).to eq Member.last
      end
    end

    context "when access_token is nil" do
      it "returns without loading any data" do
        expect(::Soundcloud).not_to receive(:new)
        expect(Member.sync_from_soundcloud(nil)).to be_nil
      end

      it "does not create a member" do
        expect { 
          Member.sync_from_soundcloud(nil) 
        }.not_to change {
          Member.count
        }
      end
    end
  end

  describe "#image(size = :large)" do
    it "returns the large image by default" do
      expect(member.image).to eq member.image_url    
    end
    it "allows passing a :large option" do
      expect(member.image(:large)).to eq member.image_url
    end
    it "allows passing a :small option" do
      expect(member.image(:small)).to eq member.image_url.gsub('t500x500', 't50x50')
    end
    it "allows passing a :medium option" do
      expect(member.image(:medium)).to eq member.image_url.gsub('t500x500', 'large')
    end
    it "defaults to large when an unknown size is passed" do
      expect(member.image(:unknown)).to eq member.image_url
    end
  end

  describe "#soundcloud_profile_url" do
    it "returns the member's soundcloud profile url" do
      expect(member.soundcloud_profile_url).to eq File.join("https://soundcloud.com", member.slug)
    end
  end

  describe "friendly id" do
    it "sets up slug as a friendly id" do
      member.save
      expect(Member.find(member.id)).to eq member
      expect(Member.find(member.slug)).to eq member
    end
  end

  describe "#sync_soundcloud_profile" do
    let(:member) { create(:member, updated_at: 1.day.ago) }

    let(:soundcloud_client) { double(::Soundcloud) }

    before(:each) do
      allow(soundcloud_client).to receive(:get).and_return(member_profile)
      allow(Sensori::Soundcloud).to receive(:app_client).and_return(soundcloud_client)
    end

    it "loads the soundcloud user's profile" do
      expect(soundcloud_client).to receive(:get).with("/users/#{member.soundcloud_id}").and_return(member_profile)
      member.sync_soundcloud_profile
    end

    it "updates the member's profile data from soundcloud" do
      expect {
        member.sync_soundcloud_profile
      }.to change { 
        member.reload.updated_at
      }

      member.reload

      expect(member.name).to eq member_profile.username
      expect(member.slug).to eq member_profile.permalink
      expect(member.image_url).to eq "https://i1.sndcdn.com/avatars-000039096498-86ivun-t500x500.jpg?0c5f27c"
      expect(member.full_name).to eq member_profile.full_name
      expect(member.bio).to eq member_profile.description
      expect(member.city).to eq member_profile.city
      expect(member.country).to eq member_profile.country
    end

    context 'when bio is set' do
      before do
        member_profile.bio = "bio!"
      end

      it "stores an html version" do
        member.sync_soundcloud_profile
        member.reload
        expect(member.bio_html).to be_present
      end
    end
  end
end
