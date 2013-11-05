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

  # GET /tagged/*
  def blog_tag_redirect
    redirect_to File.join("http://blog.sensoricollective.com/tagged", params[:tag])
  end

  # GET /post/* 
  def blog_post_redirect
    redirect_to File.join("http://blog.sensoricollective.com/post", params[:post_id])
  end

  def kickstarter
    redirect_to "http://www.kickstarter.com/projects/philsergi/sensori-collective-community-music-center", :status => 302
  end
end
