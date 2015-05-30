require 'spec_helper'

describe Playlist do  
	let(:playlist) { build(:playlist) }

	before do
		allow(BandcampPlaylistWorker).to receive(:perform_async)
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
  	context 'when link changes to a bandcamp URL' do
  		let(:playlist) { build(:playlist, :bandcamp) }

  		it 'creates a job to sync the bandcamp album id' do
  			playlist.save
  			expect(BandcampPlaylistWorker).to have_received(:perform_async).with(playlist.reload.id)
  		end
  	end

  	context 'when link changes to a non-bandcamp URL' do
  		let!(:playlist) { create(:playlist, bandcamp_album_id: 123) }

  		it 'sets bandcamp_album_id to nil' do
  			playlist.update_attributes(link: 'http://soundcloud.com/some-playlist')
  			expect(playlist.reload.bandcamp_album_id).to be_nil
  		end

  		it 'does not create a job to sync the bandcamp album id' do
  			playlist.update_attributes(link: 'http://soundcloud.com/some-playlist')
  			expect(BandcampPlaylistWorker).not_to have_received(:perform_async)
  		end
  	end

  	context 'when link was not changed' do
  		let!(:playlist) { create(:playlist) }

  		it 'does nothing' do
  			playlist.update_attributes(title: 'new title')
  			expect(BandcampPlaylistWorker).not_to have_received(:perform_async)
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
end
