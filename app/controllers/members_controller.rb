class MembersController < ApplicationController
  
  before_filter :ensure_signed_out, :only => [:sign_in]

  def sign_in
    redirect_to self.soundcloud_app_client.authorize_url
  end

  def sign_out
    reset_session
    flash[:notice] = "Successfully signed out"
    redirect_to :back
  end

  def soundcloud_connect
    if params[:code].present?
      access_token = self.soundcloud_app_client.exchange_token(:code => params[:code]).access_token
      @member = Member.sync_from_soundcloud(access_token)
    end

    if @member && @member.valid?
      session[:soundcloud_id] = @member.soundcloud_id
      flash[:notice] = "Signed in successfully!"
    else
      flash[:error] = "Error while signing in..."
    end

    redirect_to root_url
  end

  def soundcloud_app_client
    @soundcloud_app_client ||= ::Soundcloud.new({
      :client_id => Sensori::Soundcloud.client_id,
      :client_secret => Sensori::Soundcloud.secret,
      :redirect_uri => members_soundcloud_connect_url
    })
  end
end
