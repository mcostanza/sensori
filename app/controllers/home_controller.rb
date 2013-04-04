class HomeController < ApplicationController
  def prelaunch
    @prelaunch_signup = PrelaunchSignup.new
  end

  def contact_us
  end

  def send_feedback
    if params[:email].present? && params[:name].present? && params[:message].present?
      SensoriMailer.contact_us(:email => params[:email], :name => params[:name], :message => params[:message]).deliver
      flash[:notice] = "Thanks for your feedback!"
      redirect_to "/"
    else
      flash[:error] = "Sorry :'( can you try that again?"
      render :action => :contact_us
    end
  end

end
