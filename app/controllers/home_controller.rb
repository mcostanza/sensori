class HomeController < ApplicationController
  # GET /
  def index
    @latest_tracks = Track.includes(:member).latest.limit(4)
    @tutorials = Tutorial.includes(:member).where(:published => true).limit(3)
    @discussions = Discussion.includes(:member).limit(3)
  end

  # GET /about
  def about
  end

  # GET /post/* 
  def blog_post_redirect
    redirect_to File.join("http://blog.sensoricollective.com/post", params[:post_id])
  end
end
