class DiscussionsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_signed_in, :except => [:index, :show]
  before_filter :ensure_editable, :only => [:edit, :update, :destroy]

  # GET /discussions
  def index
    page = [1, params[:page].to_i].max
    @discussions = Discussion.page(page).per(10)
  end

  # GET /discussions/1
  def show
    @discussion = Discussion.find(params[:id])
    @responses = @discussion.responses
  end

  # GET /discussions/new
  def new
    @discussion = Discussion.new
  end

  # POST /discussions
  def create
    @discussion = Discussion.new(params[:discussion].merge(:member => @member))
    @discussion.save
    respond_with @discussion
  end

  # GET /discussions/1/edit
  def edit
    # @discussion is loaded in the ensure_editable before filter
  end

  # PUT /discussions/1
  def update
    # @discussion is loaded in the ensure_editable before filter
    @discussion.update_attributes(params[:discussion])
    respond_with @discussion
  end

  # DELETE /discussions/1
  def destroy
    # @discussion is loaded in the ensure_editable before filter
    @discussion.destroy
    redirect_to discussions_url, :notice => 'Discussion was successfully deleted.'
  end

  # POST /discussions/1/respond
  def respond
    @discussion = Discussion.find(params[:id])
    if @discussion.responses.create(:body => params[:response][:body], :member_id => @member.id).valid?
      redirect_to @discussion
    else
      redirect_to @discussion, :alert => 'Sorry something went wrong, please try again.'
    end
  end

  private

  def ensure_editable
    @discussion = Discussion.find(params[:id])
    if !@discussion.editable?(@member)
      redirect_to @discussion, :alert => 'Discussion is no longer editable.'
    end
  end
end
