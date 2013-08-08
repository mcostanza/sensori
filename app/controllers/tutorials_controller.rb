class TutorialsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_admin, :only => [:new, :create, :edit, :update]

  # GET /tutorials
  def index
    page = [1, params[:page].to_i].max
    @tutorials = Tutorial.where(published: true).page(page).per(6)
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
    @tutorial = Tutorial.find(params[:id])
  end

  # PUT /tutorials/1
  def update
    @tutorial = Tutorial.find(params[:id])
    @tutorial.update_attributes(params[:tutorial])
    respond_with @tutorial
  end
end
