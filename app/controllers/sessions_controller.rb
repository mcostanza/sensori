class SessionsController < ApplicationController
  before_filter :ensure_admin, :except => [:index, :show]

  # GET /sessions
  def index
    page = [1, params[:page].to_i].max
    @sessions = Session.page(page).per(6)
  end

  # GET /sessions/1
  def show
    @session = find_session
    if signed_in?
      @submission = @current_member.submissions.find_or_initialize_by_session_id(@session.id)
    end
  end

  # GET /sessions/new
  def new
    @session = Session.new
  end

  # GET /sessions/:id/edit
  def edit
    @session = find_session
  end

  # POST /sessions
  def create
    session_form = SessionForm.new(
      session: Session.new(member_id: @current_member.id),
      session_params: params[:session],
      sample_pack_params: params[:sample_packs]
    )
    
    if session_form.save
      redirect_to session_form.session, :notice => 'Session was successfully created.'
    else
      @session = session_form.session
      render :action => "new"
    end
  end

  # PUT /sessions/:id
  def update
    session_form = SessionForm.new(
      session: find_session,
      session_params: params[:session],
      sample_pack_params: params[:sample_packs]
    )

    if session_form.save
      redirect_to session_form.session, :notice => 'Session was successfully updated.'
    else
      @session = session_form.session
      render :action => "edit"
    end
  end

  # DELETE /sessions/:id
  def destroy
    find_session.destroy
    flash[:notice] = "Session was successfully deleted."
    redirect_to :sessions
  end

  # GET /sessions/:id/submissions
  def submissions
    @session = find_session
    @submissions = @session.submissions
  end

  def find_session
    Session.find(params[:id])
  end
end
