module LoginHelper
  def sign_in(soundcloud_id)
    session[:soundcloud_id] = soundcloud_id
  end

  def sign_in_as(member)
    sign_in(member.soundcloud_id)
    controller.load_member
  end
end
