class TutorialsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_signed_in, :only => [:new, :create, :edit, :update, :preview]
  before_filter :find_tutorial, :only => [:edit, :update, :preview]
  before_filter :ensure_tutorial_is_editable, :only => [:edit, :update, :preview]

  # GET /tutorials
  def index
    page = [1, params[:page].to_i].max
    conditions = signed_in? ? ["published = :true OR member_id = :member_id", { true: true, member_id: @member.id }] : { published: true }
    @tutorials = Tutorial.where(conditions).page(page).per(6)
  end

  # GET /tutorials/1
  def show
    @tutorial = Tutorial.find(params[:id])
    if !@tutorial.published?
      redirect_to(@member && @member.admin? ? edit_tutorial_path(@tutorial) : tutorials_path)
    end
  end

  # GET /tutorials/new
  def new
    @tutorial = Tutorial.new(member: @member)
  end

  # POST /tutorials
  def create
    @tutorial = Tutorial.new(params[:tutorial].merge(member: @member))
    @tutorial.save
    respond_with @tutorial
  end

  # GET /tutorials/1/edit
  def edit
  end

  # PUT /tutorials/1
  def update
    @tutorial.update_attributes(params[:tutorial])
    respond_with @tutorial
  end

  # POST /tutorials/1/preview
  def preview
    @tutorial.prepare_preview(params[:tutorial])
    render :template => "tutorials/show"
  end

  def find_tutorial
    @tutorial = Tutorial.find(params[:id])
  end

  def ensure_tutorial_is_editable
    redirect_to root_path unless @tutorial.editable?(@member)
  end
end
