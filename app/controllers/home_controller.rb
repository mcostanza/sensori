class HomeController < ApplicationController
  def index
    @latest_tracks = Track.includes(:member).latest.limit(4)
    @tutorials = Tutorial.includes(:member).limit(3)
  end

  def contact_us
  end

  # GET /post/* 
  def blog_post_redirect
    redirect_to File.join("http://blog.sensoricollective.com/post", params[:post_id])
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

  def kickstarter
    redirect_to "http://www.kickstarter.com/projects/philsergi/sensori-collective-community-music-center", :status => 302
  end

end
