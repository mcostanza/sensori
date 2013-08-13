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
  end

  describe "callbacks" do
    describe "before_save" do
      it "should call format_table_of_contents" do
        @tutorial.should_receive(:format_table_of_contents)
        @tutorial.save
      end
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

  describe "#format_table_of_contents" do
    it "should process the tutorial with a table of contents formatter and set the body_html from the result" do
      formatter = mock(Formatters::Tutorial::TableOfContents)
      Formatters::Tutorial::TableOfContents.should_receive(:new).with(@tutorial).and_return(formatter)
      formatter.should_receive(:format).and_return("processed content")
      @tutorial.format_table_of_contents
      @tutorial.body_html.should == "processed content"
    end
    it "should not do anything if body_html did not change" do
      @tutorial.stub!(:body_html_changed?).and_return(false)
      Formatters::Tutorial::TableOfContents.should_not_receive(:new)
      @tutorial.should_not_receive(:body_html=)
      @tutorial.format_table_of_contents
    end
  end

  describe "#body_components" do
    it "should return a formatted array if nil" do
      @tutorial.body_components = nil
      @tutorial.body_components.should == [{ "type" => "text", "content" => "" }, { "type" => "gallery", "content" => [] }]
    end
  end

  describe "#prepare_preview(params)" do
    before(:each) do
      @params = {
        :title => "new title",
        :description => "this is it",
        :body_html => "new body html",
        :youtube_id => "123123",
        :attachment_url => "http://s3.amazon.com/samples.zip"
      }
      @tutorial = FactoryGirl.build(:tutorial)
      @tutorial.stub!(:format_table_of_contents)
    end
    it "should set title, description, body_html, youtube_id, and attachment_url" do
      @tutorial.prepare_preview(@params)
      @tutorial.title.should == @params[:title]
      @tutorial.description.should == @params[:description]
      @tutorial.youtube_id.should == @params[:youtube_id]
      @tutorial.body_html.should == @params[:body_html]
      @tutorial.attachment_url.should == @params[:attachment_url]
    end
    it "should not set other attributes" do
      @tutorial.prepare_preview(@params.merge(id: 123, body_components: "oops"))
      @tutorial.id.should_not == 123
      @tutorial.body_components.should_not == "oops"
    end
    it "should format the table of contents" do
      @tutorial.should_receive(:format_table_of_contents)
      @tutorial.prepare_preview(@params)
    end
    it "should not save the tutorial" do
      @tutorial.should_not_receive(:save)
      @tutorial.prepare_preview(@params)
    end
  end
end
