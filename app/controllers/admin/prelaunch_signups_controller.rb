class Admin::PrelaunchSignupsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
  def index
    @prelaunch_signups = PrelaunchSignup.order(:id)
    respond_to do |format|
      format.csv { send_data @prelaunch_signups.to_csv }
    end
  end
  
  def ensure_admin
    redirect_to root_path unless current_user && current_user.admin?
  end
end
