require 'spec_helper'

describe Playlist do  
	let(:playlist) { build(:playlist) }

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
