require 'spec_helper'

describe TutorialsHelper do
	describe "#download_attachment_button(tutorial)" do
		before(:each) do
			@tutorial = FactoryGirl.build(:tutorial)
		end
		it "should return a button to download samples if the attachment_url is present" do
			expected = [
				"<a href=\"#{@tutorial.attachment_url}\" class=\"btn btn-primary attachment-button\">",
					"<i class=\"icon-white icon-download-alt\"></i> Download Samples",
				"</a>"
			].join
			assert_dom_equal(helper.download_attachment_button(@tutorial), expected)
		end
		it "should return a disabled button if the attachment_url is blank" do
			@tutorial.attachment_url = nil
			expected = [
				"<a href=\"javascript:;\" class=\"btn btn-primary attachment-button disabled\">",
					"<i class=\"icon-white icon-download-alt\"></i> Download Samples",
				"</a>"
			].join
			assert_dom_equal(helper.download_attachment_button(@tutorial), expected)
		end
	end
end
