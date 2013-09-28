require 'spec_helper'

describe DiscussionsHelper do

	describe "#discussion_owner(discussion_creator, response_creator, current_member)" do
		before(:each) do
		  @member_1 = Member.new(:name => "DJ Costanza")
			@member_2 = Member.new(:name => "Envision")
			@member_3 = Member.new(:name => "Five05")
		end
	  it "should return 'your' if the discussion creator is the current member" do
	  	helper.discussion_owner(@member_1, @member_2, @member_1).should == "your"
	  end
	  it "should return 'their' if the discussion creator is also the response creator" do
	  	helper.discussion_owner(@member_1, @member_1, @member_2).should == "their"
	  end
	  it "should return the possessive version of the discussion creator's name if it is not the current member" do
	  	helper.discussion_owner(@member_1, @member_2, @member_3).should == "DJ Costanza's"
	  end
	end

end
