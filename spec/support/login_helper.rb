module LoginHelper

  def login_user(attributes = {})
    @member = FactoryGirl.create(:member, attributes)
    session[:soundcloud_id] = @member.soundcloud_id
  end

end