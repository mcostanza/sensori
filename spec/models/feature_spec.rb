require 'spec_helper'

describe Feature do
  let(:feature_model) { build(:feature) }
  
  describe "validations" do
    it "is valid given valid attributes" do
      expect(feature_model).to be_valid
    end
    it "is invalid without a member" do
      feature_model.member = nil
      expect(feature_model).not_to be_valid
    end
    it "is invalid without a title" do
      feature_model.title = nil
      expect(feature_model).not_to be_valid
    end
    it "is invalid without a description" do
      feature_model.description = nil
      expect(feature_model).not_to be_valid
    end
    it "is invalid without an image" do
      feature_model.remove_image!
      expect(feature_model).not_to be_valid
    end
    it "is invalid without a link" do
      feature_model.link = nil
      expect(feature_model).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a member" do
      expect(Feature.reflect_on_association(:member).macro).to eq :belongs_to
    end
  end
end
