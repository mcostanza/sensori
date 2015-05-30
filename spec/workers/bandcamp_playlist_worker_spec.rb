require 'spec_helper'

describe BandcampPlaylistWorker do
	let(:playlist) { create(:playlist) }
  let(:worker) { described_class.new }

  describe "#perform(playlist_id)" do
  	let(:bandcamp_response_body) { File.read(File.join(Rails.root, "spec/data/bandcamp_album_page.html")) }
  	let(:bandcamp_response) { double('HTTParty::Response', body: bandcamp_response_body) }
  	let(:bandcamp_album_id) { 1730958122 }

  	before do
    	allow(HTTParty).to receive(:get).with(playlist.link).and_return(bandcamp_response)
  	end

  	it "requests the bandcamp link" do
  		expect(HTTParty).to receive(:get).with(playlist.link).and_return(bandcamp_response)
  		worker.perform(playlist.id)
  	end

  	it "updates the playlist with the bandcamp album id scraped from the response" do
  		expect {
  			worker.perform(playlist.id)
  		}.to change { playlist.reload.bandcamp_album_id }.to(bandcamp_album_id)
  	end
  end
end