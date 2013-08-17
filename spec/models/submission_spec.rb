require 'spec_helper'

describe Submission do
	before(:each) do
		@submission = FactoryGirl.build(:submission)
	end

	describe "validations" do
		it "should be valid given valid attributes" do
			@submission.should be_valid
		end
		it "should be invalid without a session" do
			@submission.session = nil
			@submission.should_not be_valid
		end
		it "should be invalid without a member" do
			@submission.member = nil
			@submission.should_not be_valid
		end
		it "should be invalid without a title" do
			@submission.title = nil
			@submission.should_not be_valid
		end
		it "should be invalid without an attachment_url" do
			@submission.attachment_url = nil
			@submission.should_not be_valid
		end
	end

	describe "associations" do
		it "should have a member association" do
			@submission.should respond_to(:member)
		end
		it "should have a session association" do
			@submission.should respond_to(:session)
		end 
	end
end
