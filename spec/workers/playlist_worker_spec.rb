require 'spec_helper'

describe PlaylistWorker do
  let(:worker) { described_class.new }

  describe "#perform(playlist_id)" do
    context 'bandcamp playlists' do
      let!(:playlist) { create(:playlist, :bandcamp, skip_external_id_sync: true) }

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

    context 'soundcloud playlists' do
      let!(:playlist) { create(:playlist, :soundcloud, skip_external_id_sync: true) }

      let(:soundcloud_client) { double(Soundcloud) }
      let(:soundcloud_object) { Hashie::Mash.new({ id: 99971800, uri: 'http://api.soundcloud.com/playlists/99971800' }) }

      before do
        allow(Sensori::Soundcloud).to receive(:app_client).and_return(soundcloud_client)
        allow(soundcloud_client).to receive(:get).and_return(soundcloud_object)
      end

      it "resolves the url to a soundcloud_uri" do
        expect(soundcloud_client).to receive(:get).with('/resolve', url: playlist.link).and_return(soundcloud_object)
        worker.perform(playlist.id)
      end

      it "updates the playlist with the resolved soundcloud uri" do
        expect {
          worker.perform(playlist.id)
        }.to change { playlist.reload.soundcloud_uri }.to(soundcloud_object.uri)        
      end
    end
  end
end