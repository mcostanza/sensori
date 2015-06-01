require 'spec_helper'

describe Playlist do  
	let(:playlist) { build(:playlist) }

	before do
		allow(PlaylistWorker).to receive(:perform_async)
	end

	describe "validations" do
	  it "is valid given valid attributes" do
	  	expect(playlist).to be_valid
	  end

	  it "is invalid without a title" do
	  	playlist.title = nil
	  	expect(playlist).not_to be_valid
	  end

	  it "is invalid without a link" do
	  	playlist.link = nil
	  	expect(playlist).not_to be_valid
	  end 

	  it "is invalid when link is an invalid URL" do
	  	playlist.link = 'h t t p://oops.com'
	  	expect(playlist).not_to be_valid
	  end
	end

	describe "callbacks" do
		let!(:playlist) { create(:playlist) }

		let(:bandcamp_url) { 'http://somebody.bandcamp.com/some-album' }
		let(:soundcloud_url) { 'http://soundcloud.com/something' }
		let(:other_url) { 'http://something-else.com' }

  	context 'when link changes to a bandcamp URL' do
  		it 'creates a job to sync the external album id' do
  			expect(PlaylistWorker).to receive(:perform_async).with(playlist.id)
  			playlist.update_attributes(link: bandcamp_url)
  		end

  		it 'resets soundcloud_uri if necessary' do
  			playlist.update_attribute(:soundcloud_uri, 'https://api.soundcloud.com/playlists/1')
  			playlist.update_attributes(link: bandcamp_url)
  			expect(playlist.reload.soundcloud_uri).to be_nil
  		end
  	end

  	context 'when link changes to a soundcloud URL' do
  		it 'creates a job to sync the external album id' do
  			expect(PlaylistWorker).to receive(:perform_async).with(playlist.id)
  			playlist.update_attributes(link: soundcloud_url)
  		end

  		it 'resets bandcamp_album_id if necessary' do
  			playlist.update_attribute(:bandcamp_album_id, 1)
  			playlist.update_attributes(link: soundcloud_url)
  			expect(playlist.reload.bandcamp_album_id).to be_nil
  		end
  	end

  	context 'when link changes to any other url' do
  		let!(:playlist) { create(:playlist) }

  		it 'resets bandcamp_album_id and soundcloud_uri if necessary' do
  			playlist.update_attribute(:bandcamp_album_id, 1)
  			playlist.update_attribute(:soundcloud_uri, 'https://api.soundcloud.com/playlists/1')
  			playlist.update_attributes(link: other_url)
  			playlist.reload
  			expect(playlist.bandcamp_album_id).to be_nil
  			expect(playlist.soundcloud_uri).to be_nil
  		end

  		it 'does not create a job to sync the external album id' do
  			expect(PlaylistWorker).not_to receive(:perform_async)
  			playlist.update_attributes(link: other_url)
  		end
  	end

  	context 'when link was not changed' do
  		let!(:playlist) { create(:playlist) }

  		it 'does nothing' do
  			expect(PlaylistWorker).not_to receive(:perform_async)
  			playlist.update_attributes(title: 'new title')
  		end
  	end
	end

	describe "#soundcloud?" do
	  context 'when link is on soundcloud' do
	  	let(:playlist) { build(:playlist, :soundcloud) }

	  	it "returns true" do
	  		expect(playlist.soundcloud?).to be_true
	  	end
	  end

	  context 'when link is not on soundcloud' do
	  	it "returns false" do
	  		expect(playlist.soundcloud?).to be_false
	  	end
	  end
	end

	describe "#bandcamp?" do
	  context 'when link is on bandcamp' do
	  	let(:playlist) { build(:playlist, :bandcamp) }

	  	it "returns true" do
	  		expect(playlist.bandcamp?).to be_true
	  	end
	  end

	  context 'when link is not on bandcamp' do
	  	it "returns false" do
	  		expect(playlist.bandcamp?).to be_false
	  	end
	  end
	end

	describe ".latest" do
		let!(:playlist_1) { create(:playlist, :soundcloud, soundcloud_uri: 'https://api.soundcloud.com/playlists/1') }
		let!(:playlist_2) { create(:playlist, :bandcamp, bandcamp_album_id: 1) }
		let!(:playlist_3) { create(:playlist, :bandcamp, bandcamp_album_id: nil) }
		let!(:playlist_4) { create(:playlist, :soundcloud, soundcloud_uri: nil) }

	  it "returns the most recently created Playlist with a bandcamp album id or soundcloud id" do
	  	expect(Playlist.latest).to eq playlist_2
	  end
	end
end
