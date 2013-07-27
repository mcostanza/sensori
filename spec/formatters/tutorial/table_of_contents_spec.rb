require 'spec_helper'

describe Formatters::Tutorial::TableOfContents do

  include ActionDispatch::Assertions::DomAssertions

  before(:each) do
    @tutorial = ::Tutorial.new({
      :body_html => File.read(File.join(Rails.root, "spec/data/tutorial_body.html"))
    })

    @formatter = Formatters::Tutorial::TableOfContents.new(@tutorial)
  end

  it "should have a tutorial accessor" do
    @formatter.should respond_to(:tutorial)
    @formatter.should respond_to(:tutorial=)
  end

  it "should have a tutorial parser" do
    @formatter.should respond_to(:parser)
    @formatter.should respond_to(:parser=)
  end

  describe ".initialize(tutorial)" do
    it "should set @tutorial" do
      @formatter.tutorial.should == @tutorial
    end
    it "should set @parser to a Nokogiri parser from @tutorial.body_html" do
      parser = mock(Nokogiri::HTML::Document)
      Nokogiri.should_receive(:HTML).with(@tutorial.body_html).and_return(parser)
      Formatters::Tutorial::TableOfContents.new(@tutorial).parser.should == parser
    end
  end

  describe "#node(tag, content = nil, attributes = {}" do
    describe "only tag is given" do
      it "should return an empty node" do
        node = @formatter.node(:li)
        node.should be_an_instance_of(Nokogiri::XML::Element)
        node.document.should == @formatter.parser
        assert_dom_equal("<li>", node.to_s)
      end
    end
    describe "tag and content given" do
      describe "content is a string" do
        it "should set the node's content" do
          node = @formatter.node(:li, "this is how I think")
          node.should be_an_instance_of(Nokogiri::XML::Element)
          node.document.should == @formatter.parser
          assert_dom_equal("<li>this is how I think</li>", node.to_s)
        end
      end
      describe "content is a node" do
        it "should add the content as a child" do
          content_node = @formatter.node(:li, "this is how I think")
          node = @formatter.node(:ul, content_node)
          node.should be_an_instance_of(Nokogiri::XML::Element)
          node.document.should == @formatter.parser
          assert_dom_equal("<ul><li>this is how I think</li></ul>", node.to_s)
        end
      end
    end
    describe "tag, content, and attributes given" do
      it "should set each attribute on the node" do
        node = @formatter.node(:li, "this is how I think", :class => "really-fast")
        node.should be_an_instance_of(Nokogiri::XML::Element)
        node.document.should == @formatter.parser
        assert_dom_equal("<li class=\"really-fast\">this is how I think</li>", node.to_s)
      end
    end
  end

  describe "#headings" do
    it "should return all h3 and h4 elements from @parser in the order they occur in @tutorial.body_html" do
      headings = @formatter.headings

      headings.each { |node| node.should be_an_instance_of(Nokogiri::XML::Element) }

      expected_content = [
        "<h3>Overview</h3>",
        "<h3>Why Recreate This Beat?</h3>",
        "<h3>Recreating the Drums</h3>",
        "<h4>Kick Drum</h4>",
        "<h4>Snare Drum</h4>",
        "<h4>Closed Hi-Hat, Open Hi-Hat, Ride Cymbal</h4>",
        "<h3>Recording The Base Drum Pattern</h3>"
      ].join

      assert_dom_equal(expected_content, headings.to_s)
    end
    it "should be memoized" do
      @formatter.headings
      @formatter.parser.should_not_receive(:search)
      @formatter.headings
    end
  end

  describe "#format" do
    it "should return a string containing tutorial.body_html with a table of contents prepended and id's added to each heading/subheading" do
      expected = File.read(File.join(Rails.root, "spec/data/tutorial_body_with_table_of_contents.html")).gsub("\n", "").gsub("\r", "")
      actual = @formatter.format.gsub("\n", "").gsub("\r", "")
      assert_dom_equal(expected, actual)
    end
  end

end

