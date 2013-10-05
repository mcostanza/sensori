module DiscussionsHelper

	def discussion_owner(discussion_creator, response_creator, current_member)
		return "your" if discussion_creator == current_member
		return "their" if discussion_creator == response_creator
		discussion_creator.name.possessive
	end

  def discussion_categories
    [nil] + Discussion::CATEGORIES
  end

  def discussion_categories_for_select
    Discussion::CATEGORIES.map { |category| [category.titleize, category] }
  end

  def category_name(category)
    return 'All' if category.blank?
    category.titleize
  end

end
