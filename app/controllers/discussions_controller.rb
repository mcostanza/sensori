class DiscussionsController < ApplicationController
  before_filter :ensure_signed_in, :except => [:index, :show]

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
    @discussion = Discussion.new(params[:discussion].merge(:member_id => @member.id))

    if @discussion.save
      redirect_to @discussion, :notice => 'Discussion was successfully created.'
    else
      render :action => "new"
    end
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
end
