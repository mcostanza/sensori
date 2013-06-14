class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_member_if_signed_in

  def load_member_if_signed_in
    @member = Member.find_by_soundcloud_id(session[:soundcloud_id]) if signed_in?
  end

  def signed_in?
    session[:soundcloud_id].present?
  end
  helper_method :signed_in?

  def signed_out?
    !signed_in?
  end
  helper_method :signed_out?

  def ensure_signed_in
    redirect_to root_path unless signed_in?
  end

  def ensure_signed_out
    redirect_to root_path unless signed_out?
  end

end
