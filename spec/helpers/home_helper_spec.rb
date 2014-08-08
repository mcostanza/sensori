require 'spec_helper'

describe HomeHelper do

	describe "#cover_image" do
		before(:each) do
      @cover_image_ids = (1..8).to_a
      helper.instance_variable_set(:@cover_image_ids, @cover_image_ids)
		end
    it "should setup the @cover_image_ids instance variable" do
      helper.instance_variable_set(:@cover_image_ids, nil)
      helper.cover_image
      helper.instance_variable_get(:@cover_image_ids).should_not be_nil
    end
    it "should return the filename of a random cover image" do
      @cover_image_ids.should_receive(:sample).and_return(4)
      helper.cover_image.should == "carousel-bg-4.jpg"
    end
    it "should not reuse the same cover image within the same request" do
      @cover_image_ids.should_receive(:sample).and_return(5)
      helper.cover_image.should == "carousel-bg-5.jpg"
      @cover_image_ids.should_not include(5) 
    end
	end
end
