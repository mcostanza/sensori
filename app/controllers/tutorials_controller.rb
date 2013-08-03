class TutorialsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_admin, :only => [:new, :create, :edit, :update]

  # GET /tutorials
  def index
    page = [1, params[:page].to_i].max
    @tutorials = Tutorial.page(page).per(6)
  end

  # GET /tutorials/1
  def show
    @tutorial = Tutorial.find(params[:id])
  end

  # GET /tutorials/new
  def new
    @tutorial = Tutorial.new(member: @member)
  end

  # POST /tutorials
  def create
    @tutorial = Tutorial.new(params[:tutorial].merge(member: @member))
    if @tutorial.save
      flash[:notice] = "Tutorial was successfully created."
    else
      flash[:error] = "Tutorial could not be created."
    end
    respond_with @tutorial
  end

  # GET /tutorials/1/edit
  def edit
    @tutorial = Tutorial.find(params[:id])
  end

  # PUT /tutorials/1
  def update
    @tutorial = Tutorial.find(params[:id])
    if @tutorial.update_attributes(params[:tutorial])
      flash[:notice] = "Tutorial was successfully updated."
    else
      flash[:error] = "Tutorial could not be updated."
    end
    respond_with @tutorial
  end
end
