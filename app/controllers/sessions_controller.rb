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
    if signed_in?
      @submission = @member.submissions.find_or_initialize_by_session_id(@session.id)
    end
  end

  # GET /sessions/new
  def new
    @session = Session.new
  end

  # GET /sessions/:id/edit
  def edit
    @session = Session.find(params[:id])
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

  # PUT /sessions/:id
  def update
    @session = Session.find(params[:id])

    if @session.update_attributes(params[:session])
      redirect_to @session, :notice => 'Session was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /sessions/:id
  def destroy
    @session = Session.find(params[:id])
    @session.destroy
    flash[:notice] = "Session was successfully deleted."
    redirect_to :sessions
  end

  # GET /sessions/:id/submissions
  def submissions
    @session = Session.find(params[:id])
    @submissions = @session.submissions
  end
end
