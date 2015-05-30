require 'spec_helper'

describe HomeHelper do
  describe "#carousel_link(item)" do
    context "when the item has a link" do
      let(:item) { build(:feature) }

      it "returns the item link" do
        expect(helper.carousel_link(item)).to eq item.link
      end
    end
    
    context 'when the item does not have a link' do
      let(:item) { build(:tutorial) }
      
      it "returns the item" do
        expect(helper.carousel_link(item)).to eq item
      end
    end
  end

  describe "#carousel_link_options(item)" do
    context 'when the item has an external link' do
      let(:item) { build(:feature, link: 'http://google.com') }

      it "returns { target: '_blank' }" do
        expect(helper.carousel_link_options(item)).to eq({ target: '_blank' })
      end
    end
    
    context 'when the item has an internal link' do
      let(:item) { build(:feature, link: 'http://sensoricollective.com/sessions/1') }

      it "returns an empty hash" do
        expect(helper.carousel_link_options(item)).to eq({})
      end
    end

    context 'when the item has a nil link' do
      let(:item) { build(:feature, link: nil) }

      it "returns { target: '_blank' }" do
        expect(helper.carousel_link_options(item)).to eq({ target: '_blank' })
      end
    end

    context 'when the item does not have a link defined' do
      let(:item) { build(:tutorial) }

      it "returns an empty hash" do
        expect(helper.carousel_link_options(item)).to eq({})
      end  
    end
  end
end
