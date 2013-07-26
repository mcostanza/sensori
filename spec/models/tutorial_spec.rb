require 'spec_helper'

describe Tutorial do
  before(:each) do
    @tutorial = FactoryGirl.build(:tutorial)
  end

  describe "validations" do
    it "should be valid given valid attributes" do
      @tutorial.should be_valid
    end
    it "should be invalid without a title" do
      @tutorial.title = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without a description" do
      @tutorial.description = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without a member" do
      @tutorial.member = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without body_html" do
      @tutorial.body_html = nil
      @tutorial.should_not be_valid
    end
    it "should be invalid without body_components" do
      @tutorial.body_components = nil
      @tutorial.should_not be_valid
    end
  end

  it "should set slug from the title when saving" do
    @tutorial.save
    @tutorial.slug.should == @tutorial.title.parameterize
  end

  describe "#youtube_image_url" do
    it "should return an image url based on self.youtube_id" do
      @tutorial.youtube_image_url.should == "http://img.youtube.com/vi/#{@tutorial.youtube_id}/0.jpg"
    end
  end

  describe "#youtube_embed_url" do
    it "should return an embed url based on self.youtube_id" do
      @tutorial.youtube_embed_url.should == "http://www.youtube.com/embed/#{@tutorial.youtube_id}"
    end
  end

  describe "#youtube_video_url" do
    it "should return a video url based on self.youtube_id" do
      @tutorial.youtube_video_url.should == "http://www.youtube.com/watch?v=#{@tutorial.youtube_id}"
    end
  end

end
