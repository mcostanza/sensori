module TutorialsHelper

	def download_attachment_button(tutorial)
		if tutorial.attachment_url.present?
			href = tutorial.attachment_url
			classnames = "btn btn-primary attachment-button"
		else
			href = "javascript:;"
			classnames = "btn btn-primary attachment-button disabled"
		end

		link_to raw("<i class=\"icon-white icon-download-alt\"></i> Download Samples"), href, :class => classnames
	end

end
