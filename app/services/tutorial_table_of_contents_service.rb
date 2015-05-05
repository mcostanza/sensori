class TutorialTableOfContentsService
  attr_accessor :tutorial, :parser

  def initialize(tutorial)
    @tutorial = tutorial
    @parser = Nokogiri::HTML(@tutorial.body_html)
  end

  # Creates a detached child element that belongs to @parser.
  def node(tag, content = nil, attributes = {})
    node = Nokogiri::XML::Node.new(tag.to_s, @parser)

    attributes.each { |name, value| node[name] = value }

    if content.is_a?(Nokogiri::XML::Node)
      node.add_child(content)
    elsif content.is_a?(String)
      node.content = content
    end

    node
  end

  # Returns an array of all h3 and h4 tags within @parser, in the same order
  # they appear in the document.
  def headings
    return @headings if @headings

    # This array contains all h3 elements, then all h4 elements (incorrect order).
    headings = @parser.search("h3,h4")

    # Add a data-toc to each h3/h4 so they can be found in the correct order
    headings.each { |tag| tag.set_attribute("data-toc", "1") }

    # This array contains all h3/h4 elements in order
    @headings = @parser.search("[@data-toc]")

    # Remove the data-toc attributes so the output is clean
    headings.each { |tag| tag.remove_attribute("data-toc") }

    @headings
  end

  def format
    # ul element to contain table of contents
    toc = node(:ul)

    # Placeholder for nested ul for subheadings
    nested_ul = nil

    self.headings.each_with_index do |heading, index|

      # Add an id to the heading
      id = "bookmark-#{index}"
      heading['id'] = id

      # Create a table of contents entry with an anchor link to the heading
      li = node(:li, node(:a, heading.content, { "href" => "##{id}" }))

      # h3 - heading
      if heading.name == "h3"
        # Add the li directly to the table of contents
        toc.add_child(li)

        # Reset the subheadings nested ul
        nested_ul = nil

      # h4 - subheading
      else

        # Check if this is the first in a series of subheadings
        if nested_ul.nil?
          nested_ul = node(:ul)

          # Add the nested ul to the table of contents
          toc.add_child(nested_ul)
        end

        # Add the li to the nested ul
        nested_ul.add_child(li)
      end
    end

    # Add "Table of Contents" h3 and ul as the first elements of the parser body
    if toc.children.size > 0
      @parser.at("body").children.first.before(node(:h3, "Table of Contents"))
      @parser.at("body").children.first.after(toc)
    end

    # Return a string containing modified tutorial content
    @parser.at("body").inner_html
  end
end