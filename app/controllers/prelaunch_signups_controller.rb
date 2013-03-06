class PrelaunchSignupsController < ApplicationController
  
  # POST /prelaunch_signups
  def create
    PrelaunchSignup.create(params[:prelaunch_signup])
    flash[:notice] = "Thank you for signing up!"
    redirect_to root_path
  end
end
