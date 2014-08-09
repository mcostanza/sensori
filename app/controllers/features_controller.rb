class FeaturesController < ApplicationController
  before_filter :ensure_admin

  # GET /features
  def index
    @features = Feature.all
  end

  # GET /features/1
  def show
    @feature = Feature.find(params[:id])
  end

  # GET /features/new
  def new
    @feature = Feature.new
  end

  # GET /features/1/edit
  def edit
    @feature = Feature.find(params[:id])
  end

  # POST /features
  def create
    @feature = Feature.new(params[:feature].merge(:member_id => @current_member.id))

    if @feature.save
      redirect_to @feature, :notice => 'Feature was successfully created.'
    else
      render :action => "new"
    end
  end

  # PUT /features/1
  def update
    @feature = Feature.find(params[:id])

    if @feature.update_attributes(params[:feature])
      redirect_to @feature, :notice => 'Feature was successfully updated.'
    else
      render :action => "edit"
    end
  end

  # DELETE /features/1
  def destroy
    @feature = Feature.find(params[:id])
    @feature.destroy
    flash[:notice] = "Feature was successfully deleted."
    redirect_to :features
  end
end
