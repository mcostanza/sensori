class SubmissionsController < ApplicationController
	 respond_to :html, :json

	 before_filter :find_session
	 before_filter :find_submission, :except => [:create]
	 before_filter :format_submission_params, :except => [:destroy]

	# POST /sessions/:session_id/submissions
	def create
		@submission = Submission.new(params[:submission].merge(session_id: @session.id, member_id: @current_member.id))
		@submission.save
		respond_with @session, @submission
  end

  # PUT /sessions/:session_id/submissions/:id
  def update
  	@submission.update_attributes(params[:submission])
  	respond_with @session, @submission
  end

  # DELETE /sessions/:session_id/submissions/:id
  def destroy
  	@submission.destroy
  	redirect_to @session
  end

  def find_session
  	@session = Session.find(params[:session_id])
  end

  def find_submission
  	@submission = @session.submissions.find(params[:id]) if @session
  end

  def format_submission_params
  	[:session, :session_id, :member, :member_id].each do |attribute| 
  		params[:submission].delete(attribute)
  	end
  end
end
