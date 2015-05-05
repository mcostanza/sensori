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

  describe "#carousel_link(item)" do
    it "should return 'link' if the item has one" do
      item = double('item', :link => 'ok')
      helper.carousel_link(item).should == 'ok'
    end
    it "should return the item otherwise" do
      item = double('item')
      helper.carousel_link(item).should == item
    end
  end

  describe "#carousel_link_options(item)" do
    it "should return { :target => '_blank' } when link is defined and is external" do
      item = double('item', :link => 'http://google.com')
      helper.carousel_link_options(item).should == { :target => '_blank' }
    end
    it "should return { } when link is defined and is internal" do
      item = double('item', :link => 'http://sensoricollective.com/sessions/1')
      helper.carousel_link_options(item).should == { }
      item = double('item', :link => 'http://www.SensoriCollective.com/sessions/1')
      helper.carousel_link_options(item).should == { }
    end
    it "should not fail if link is nil" do
      item = double('item', :link => nil)
      lambda { helper.carousel_link_options(item) }.should_not raise_error
    end
    it "should return { } if link is not defined" do
      item = double('item')
      helper.carousel_link_options(item).should == { }
    end
  end
end
