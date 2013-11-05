module LoginHelper

  def login_user(attributes = {})
    @current_member = FactoryGirl.create(:member, attributes)
    session[:soundcloud_id] = @current_member.soundcloud_id
  end

end
