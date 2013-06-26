class TutorialsController < ApplicationController

  before_filter :load_member_if_signed_in
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
    @tutorial = Tutorial.new
  end

  # POST /tutorials
  def create
    @tutorial = Tutorial.new(params[:tutorial].merge(member: @member))
    if @tutorial.save
      redirect_to @tutorial, notice: "Tutorial was successfully created."
    else
      flash[:error] = "Tutorial could not be created."
      render action: "new"
    end
  end

  # GET /tutorials/1/edit
  def edit
    @tutorial = Tutorial.find(params[:id])
  end

  # PUT /tutorials/1
  def update
    @tutorial = Tutorial.find(params[:id])
    if @tutorial.update_attributes(params[:tutorial])
      redirect_to @tutorial, notice: "Tutorial was successfully updated."
    else
      flash[:error] = "Tutorial could not be updated."
      render action: "edit"
    end
  end
end
