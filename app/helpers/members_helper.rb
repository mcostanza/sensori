module MembersHelper
  def member_location(member)
    [member.city, member.country].reject { |v| v.blank? }.join(", ")
  end
end

