class ResponsesController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_signed_in, :only => [:create]

  # POST /responses
  def create
    @response = Response.new(params[:response].merge(:member => @current_member))
    @response.save
    respond_with @response
  end
end
