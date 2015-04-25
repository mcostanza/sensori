require 'spec_helper'

describe Track do
  let(:track) { build(:track) }

  describe "validations" do
    it "is valid given valid attributes" do
      expect(track).to be_valid
    end
    it "is invalid without a member" do
      track.member = nil
      expect(track).not_to be_valid
    end
    it "is invalid without a soundcloud_id" do
      track.soundcloud_id = nil
      expect(track).not_to be_valid
    end
    it "is invalid with a non-unique soundcloud_id" do
      track.save
      other_track = build(:track, :soundcloud_id => track.soundcloud_id)
      expect(other_track).not_to be_valid
    end
    it "is invalid without a title" do
      track.title = nil
      expect(track).not_to be_valid
    end
    it "is invalid without a permalink_url" do
      track.permalink_url = nil
      expect(track).not_to be_valid
    end
    it "is invalid without a non-unique permalink_url" do
      track.save
      other_track = build(:track, :permalink_url => track.permalink_url)
      expect(other_track).not_to be_valid
    end
    it "is invalid without posted_at" do
      track.posted_at = nil
      expect(track).not_to be_valid
    end
    it "is invalid without an artwork_url" do
      track.artwork_url = nil
      expect(track).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a member" do
      expect(Track.reflect_on_association(:member).macro).to eq :belongs_to
    end
  end

  describe "scopes" do
    describe ".latest(limit)" do
      it "returns tracks ordered by posted_at DESC" do
        expect(Track.latest.arel.orders).to eq ["posted_at DESC"]
      end
    end
  end

  describe "#to_json(options = {})" do
    let(:extended_attributes) do
      track.attributes.merge({
        "posted_at" => track.posted_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
        "member" => {
          'name' => track.member.name,
          'slug' => track.member.slug,
          'image_url' => track.member.image_url
        }
      })
    end

    it "return a JSON object with attributes and the member association included" do
      expect(JSON.parse(track.to_json)).to eq extended_attributes
    end
  end
end
