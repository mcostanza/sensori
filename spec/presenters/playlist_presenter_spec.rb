require 'spec_helper'

describe PlaylistPresenter do
  let(:playlist) { build(:playlist) }
  let(:playlist_presenter) { described_class.new(playlist) }

  it "has an accessor for playlist" do
  	expect(playlist_presenter).to respond_to(:playlist)
  	expect(playlist_presenter).to respond_to(:playlist=)
  end

  describe ".initialize(playlist)" do
    it "sets playlist" do
    	expect(playlist_presenter.playlist).to eq playlist
    end
  end

  describe "#partial" do
    context 'with a bandcamp playlist' do
      let(:playlist) { build(:playlist, :bandcamp) }
      
      it "returns the bandcamp partial" do
        expect(playlist_presenter.partial).to eq "/playlists/bandcamp"
      end
    end

    context 'with a soundcloud playlist' do
      let(:playlist) { build(:playlist, :soundcloud) }
      
      it "returns the soundcloud partial" do
        expect(playlist_presenter.partial).to eq "/playlists/soundcloud"
      end
    end
  end
end