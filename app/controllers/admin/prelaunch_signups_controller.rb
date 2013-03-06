class Admin::PrelaunchSignupsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @prelaunch_signups = PrelaunchSignup.all
  end
  
  def ensure_admin
    redirect_to root_path unless current_user && current_user.admin?
  end
end
