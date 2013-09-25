require 'spec_helper'

describe String do

	describe "#possessive" do
	  it "should return the string with 's appended when it does not end with s" do
	  	"Mike".possessive.should == "Mike's"
	  end
	  it "should return the string with ' appended when it ends with s" do
	  	"Jones".possessive.should == "Jones'"
	  end
	end

end