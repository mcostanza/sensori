class SessionsController < ApplicationController
  before_filter :ensure_admin, :except => [:index, :show]

  # GET /sessions
  def index
    page = [1, params[:page].to_i].max
    @sessions = Session.page(page).per(6)
  end

  # GET /sessions/1
  def show
    @session = Session.find(params[:id])
  end

  # GET /sessions/new
  def new
    @session = Session.new
  end

  # POST /sessions
  def create
    @session = Session.new(params[:session].merge(:member_id => @member.id))

    if @session.save
      redirect_to @session, :notice => 'Session was successfully created.'
    else
      render :action => "new"
    end
  end
end
