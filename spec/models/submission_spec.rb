require 'spec_helper'

describe Submission do
	let(:submission) { build(:submission) }
	
	describe "validations" do
		it "is valid given valid attributes" do
			expect(submission).to be_valid
		end
		it "is invalid without a session" do
			submission.session = nil
			expect(submission).not_to be_valid
		end
		it "is invalid without a member" do
			submission.member = nil
			expect(submission).not_to be_valid
		end
		it "is invalid without a title" do
			submission.title = nil
			expect(submission).not_to be_valid
		end
		it "is invalid without an attachment_url" do
			submission.attachment_url = nil
			expect(submission).not_to be_valid
		end
	end

	describe "associations" do
		it "belongs to a member" do
			expect(Submission.reflect_on_association(:member).macro).to eq :belongs_to
		end
		it "belongs to a session" do
			expect(Submission.reflect_on_association(:session).macro).to eq :belongs_to
		end 
	end
end
