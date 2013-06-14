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
      soundcloud_profile = ::Soundcloud.new(:access_token => access_token).get("/me") if access_token.present?
      
      if soundcloud_profile.present?
        @member = Member.find_or_initialize_by_soundcloud_id({
          :soundcloud_id => soundcloud_profile.id,
          :name => soundcloud_profile.username,
          :slug => soundcloud_profile.permalink,
          :image_url => soundcloud_profile.avatar_url,
          :soundcloud_access_token => access_token
        })
        @member.save
      end
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
