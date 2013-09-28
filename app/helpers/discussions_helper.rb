module DiscussionsHelper

	def discussion_owner(discussion_creator, response_creator, current_member)
		return "your" if discussion_creator == current_member
		return "their" if discussion_creator == response_creator
		discussion_creator.name.possessive
	end

end
