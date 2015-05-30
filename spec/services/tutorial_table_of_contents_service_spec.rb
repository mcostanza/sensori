require 'spec_helper'

describe TutorialTableOfContentsService do
  include ActionDispatch::Assertions::DomAssertions

  let(:tutorial) { build(:tutorial, body_html: File.read(File.join(Rails.root, "spec/data/tutorial_body.html"))) }

  let(:formatter) { described_class.new(tutorial) }

  it "has a tutorial accessor" do
    expect(formatter).to respond_to(:tutorial)
    expect(formatter).to respond_to(:tutorial=)
  end

  it "has a tutorial parser" do
    expect(formatter).to respond_to(:parser)
    expect(formatter).to respond_to(:parser=)
  end

  describe ".initialize(tutorial)" do
    it "sets tutorial" do
      expect(formatter.tutorial).to eq tutorial
    end
    it "sets @parser to a Nokogiri parser for tutorial.body_html" do
      parser = double(Nokogiri::HTML::Document)
      expect(Nokogiri).to receive(:HTML).with(tutorial.body_html).and_return(parser)
      expect(formatter.parser).to eq parser
    end
  end

  describe "#node(tag, content = nil, attributes = {}" do
    context "when only tag is given" do
      let(:node) { formatter.node(:li) }

      it "return an empty node" do
        expect(node).to be_an_instance_of(Nokogiri::XML::Element)
        expect(node.document).to eq formatter.parser
        assert_dom_equal("<li>", node.to_s)
      end
    end

    context "when tag and content given" do
      context "when content is a string" do
        let(:node) { formatter.node(:li, "this is how I think") }
        
        it "sets the node's content" do
          expect(node).to be_an_instance_of(Nokogiri::XML::Element)
          expect(node.document).to eq formatter.parser
          assert_dom_equal("<li>this is how I think</li>", node.to_s)
        end
      end

      describe "content is a node" do
        let(:content_node) { formatter.node(:li, "this is how I think") }
        let(:node) { formatter.node(:ul, content_node) }

        it "adds the content as a child" do
          expect(node).to be_an_instance_of(Nokogiri::XML::Element)
          expect(node.document).to eq formatter.parser
          assert_dom_equal("<ul><li>this is how I think</li></ul>", node.to_s)
        end
      end
    end

    context "when tag, content, and attributes given" do
      let(:node) { formatter.node(:li, "this is how I think", :class => "really-fast") }

      it "sets each attribute on the node" do
        expect(node).to be_an_instance_of(Nokogiri::XML::Element)
        expect(node.document).to eq formatter.parser
        assert_dom_equal("<li class=\"really-fast\">this is how I think</li>", node.to_s)
      end
    end
  end

  describe "#headings" do
    let(:headings) { formatter.headings }

    let(:expected_content) do
      "<h3>Overview</h3>"\
      "<h3>Why Recreate This Beat?</h3>"\
      "<h3>Recreating the Drums</h3>"\
      "<h4>Kick Drum</h4>"\
      "<h4>Snare Drum</h4>"\
      "<h4>Closed Hi-Hat, Open Hi-Hat, Ride Cymbal</h4>"\
      "<h3>Recording The Base Drum Pattern</h3>"
    end

    it "returns all h3 and h4 elements from @parser in the order they occur in tutorial.body_html" do
      headings.each do |node| 
        expect(node).to be_an_instance_of(Nokogiri::XML::Element)
      end
      assert_dom_equal(expected_content, headings.to_s)
    end

    it "is memoized" do
      formatter.headings
      expect(formatter.parser).not_to receive(:search)
      formatter.headings
    end
  end

  describe "#format" do
    let(:actual) { formatter.format.gsub("\n", "").gsub("\r", "") }

    context 'with a tutorial that has headings and subheadings' do
      let(:expected) { File.read(File.join(Rails.root, "spec/data/tutorial_body_with_table_of_contents.html")).gsub("\n", "").gsub("\r", "") }
      
      
      it "returns a string containing tutorial.body_html with a table of contents prepended and id's added to each heading/subheading" do
        assert_dom_equal(expected, actual)
      end
    end
    
    context 'with a tutorial that does not have headings or subheadings' do
      let(:tutorial) { build(:tutorial, body_html: File.read(File.join(Rails.root, "spec/data/tutorial_body_no_headings.html"))) }
      let(:expected) { tutorial.body_html.gsub("\n", "").gsub("\r", "") }

      it "returns a string containing tutorial.body_html unmodified if there are no headings/subheadings" do
        assert_dom_equal(expected, actual)
      end
    end
  end
end