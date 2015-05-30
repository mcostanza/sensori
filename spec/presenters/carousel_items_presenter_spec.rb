require 'spec_helper'

describe CarouselItemsPresenter do
  let(:tutorials) { build_list(:tutorial, 2) }
  let(:features) { build_list(:feature, 2) }
  let(:models) { tutorials + features }
  let(:background_image_ids) { [1, 2, 3, 4] }
  let(:carousel_items_presenter) { described_class.new(models, background_image_ids) }

  it "has an accessor for models" do
  	expect(carousel_items_presenter).to respond_to(:models)
  	expect(carousel_items_presenter).to respond_to(:models=)
  end

  it "has an accessor for background_image_ids" do
  	expect(carousel_items_presenter).to respond_to(:background_image_ids)
  	expect(carousel_items_presenter).to respond_to(:background_image_ids=)  	
  end

  it "has a UNIQUE_BACKGROUND_IMAGES constant" do
    expect(described_class.constants).to include(:UNIQUE_BACKGROUND_IMAGES)
  end

  describe ".initialize(models, background_image_ids = self.randomized_background_image_ids)" do
    it "sets models" do
    	expect(carousel_items_presenter.models).to eq models
    end

    it "sets background_image_ids" do
    	expect(carousel_items_presenter.background_image_ids).to eq background_image_ids
    end
  end

  describe "#carousel_items" do
    let(:carousel_items) { carousel_items_presenter.carousel_items }

    it "returns an array of objects with a model and background_image_id" do
    	expect(carousel_items).to be_instance_of Array
    	expect(carousel_items.size).to eq 4

    	expect(carousel_items.map(&:model)).to eq models
    	expect(carousel_items.map(&:background_image_id)).to eq background_image_ids
    end

    context 'when there are more models than background_image_ids' do
      let(:tutorials) { build_list(:tutorial, 3) }
      let(:features) { build_list(:feature, 3) }

      it "repeats the background_image_ids sequence" do
        expect(carousel_items.map(&:model)).to eq models
        expect(carousel_items.map(&:background_image_id)).to eq [1, 2, 3, 4, 1, 2]
      end
    end
  end

  describe "#randomized_background_image_ids" do
    let(:unique_background_images) { described_class::UNIQUE_BACKGROUND_IMAGES }
    it "returns a randomized array of numbers containing 1..UNIQUE_BACKGROUND_IMAGES" do
      numbers = carousel_items_presenter.randomized_background_image_ids
      expect(numbers.size).to eq unique_background_images
      expect(numbers.sort).to eq (1..unique_background_images).to_a
    end
  end
end