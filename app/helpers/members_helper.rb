module MembersHelper
  def member_location(member)
    [member.city, member.country].reject { |v| v.blank? }.join(", ")
  end

  def member_profile_full_name(member)
    return if member.full_name.blank?
    content_tag(:span, "(#{member.full_name})", :class => "full-name muted")
  end

  def member_profile_location(member)
    location = member_location(member)
    return if location.blank?
    content_tag(:p) do
      content_tag(:i, "", :class => "icon-map-marker") + " " + location
    end
  end
end

