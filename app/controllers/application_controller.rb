class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :load_member_if_signed_in

  def load_member_if_signed_in
    load_member if signed_in?
  end

  def load_member
    @current_member = Member.where(:soundcloud_id => session[:soundcloud_id]).first
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

  def ensure_admin
    redirect_to root_path unless @current_member && @current_member.admin?
  end

  def paginated_respond_with(resource)
    respond_with(resource) do |format|
      format.json { render :json => { :models => resource, :total_pages => resource.total_pages, :page => resource.current_page } }
    end
  end

  protected

  def self.responder
    BasicResponder
  end

end
