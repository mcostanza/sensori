class TracksController < ApplicationController
  def index
    page = [1, params[:page].to_i].max
    @tracks = Track.includes(:member).latest.page(page).per(12)    
  end
end
