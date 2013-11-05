require 'spec_helper'

describe SubmissionsController do
  include LoginHelper

  before(:each) do
    @session = FactoryGirl.create(:session)
  end

  describe "before filters" do
    describe "#find_session" do
      it "should find and assign @session from params[:session_id]" do
        controller.stub(:params).and_return(:session_id => @session.id)
        Session.should_receive(:find).with(@session.id).and_return(@session)
        controller.find_session
        controller.instance_variable_get(:@session).should == @session
      end
    end
    describe "#find_submission" do
      it "should find and assign @submission from params[:id] and @sesssion" do
        controller.stub(:params).and_return(:id => 1)
        
        controller.instance_variable_set(:@session, @session)
        submission = double(Submission)
        submissions = double('submissions')
        @session.stub(:submissions).and_return(submissions)
        submissions.should_receive(:find).with(1).and_return(submission)

        controller.find_submission
        controller.instance_variable_get(:@submission).should == submission
      end
    end
    describe "#format_submission_params" do
      it "should remove :session, :session_id, :member, and :member_id from params[:submission] without changing other params" do
        controller.stub(:params).and_return({
          :submission => {
            :title => 'title',
            :session => 1,
            :session_id => 2,
            :member => 3,
            :member_id => 4
          },
          :other => 'stuff'
        })

        controller.format_submission_params

        controller.params.should == {
          :submission => { 
            :title => 'title'
          },
          :other => 'stuff'
        }
      end
    end
  end

  describe "POST 'create'" do
    before(:each) do
      request.env['CONTENT_TYPE'] = 'application/json'

      @submission_params = {
        :title => "My Beat",
        :attachment_url => "http://s3.amazon.com/beat.mp3"
      }
      @params = {
        :session_id => @session.id,
        :submission => @submission_params
      }
      @submission = Submission.new
      @submission.id = 10
      @submission.stub(:save).and_return(true)
      Submission.stub(:new).and_return(@submission)
    end
    describe "before filters" do
      before(:each) do
        controller.stub(:create)
        controller.stub(:load_member_if_signed_in)
        controller.stub(:find_session)
        controller.stub(:format_submission_params)
      end
      it "should have the load_member_if_signed_in before filter" do
        controller.should_receive(:load_member_if_signed_in)
        post :create, @params
      end
      it "should have the find_session before filter" do
        controller.should_receive(:find_session)
        post :create, @params
      end
      it "should have the format_submission_params before filter" do
        controller.should_receive(:format_submission_params)
        post :create, @params
      end
    end
    describe "when logged in" do
      before(:each) do 
        login_user
      end
      it "should initialize a submission from the session and member and params[:submission]" do
        Submission.should_receive(:new).with(@submission_params.merge(:session_id => @session.id, :member_id => @current_member.id).stringify_keys).and_return(@submission)
        post 'create', @params
      end
      it "should attempt to save the submission" do
        @submission.should_receive(:save)
        post 'create', @params
      end
      describe "valid params given" do
        it "should respond with the session and submission" do
          controller.should_receive(:respond_with).with(@session, @submission)
          post 'create', @params
        end
      end
      describe "invalid params given" do
        before(:each) do
          @submission.stub(:save).and_return(false)
        end
        it "should respond with the session and submission" do
          controller.should_receive(:respond_with).with(@session, @submission)
          post 'create', @params
        end
      end
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      request.env['CONTENT_TYPE'] = 'application/json'

      @submission_params = {
        :title => "My Beat",
        :attachment_url => "http://s3.amazon.com/beat.mp3"
      }
      @params = {
        :id => 123,
        :session_id => @session.id,
        :submission => @submission_params
      }
      @submission = Submission.new
      @submission.id = 123
      @submission.stub(:update_attributes).and_return(true)
      @session.stub(:submissions).and_return(double('submissions', :find => @submission))
      Session.stub(:find).and_return(@session)
    end
    describe "before filters" do
      before(:each) do
        controller.stub(:update)
        controller.stub(:load_member_if_signed_in)
        controller.stub(:find_session)
        controller.stub(:find_submission)
      end
      it "should have the load_member_if_signed_in before filter" do
        controller.should_receive(:load_member_if_signed_in)
        put :update, @params
      end
      it "should have the find_session before filter" do
        controller.should_receive(:find_session)
        put :update, @params
      end
      it "should have the find_submission before filter" do
        controller.should_receive(:find_submission)
        put :update, @params
      end
    end
    describe "when logged in" do
      before(:each) do 
        login_user
      end
      it "should attempt to update the submission from params[:submission]" do
        @submission.should_receive(:update_attributes).with(@submission_params.stringify_keys)
        put :update, @params
      end
      describe "valid params given" do
        it "should respond with the session and submission" do
          controller.should_receive(:respond_with).with(@session, @submission)
          put :update, @params
        end
      end
      describe "invalid params given" do
        before(:each) do
          @submission.stub(:update_attributes).and_return(false)
        end
        it "should respond with the session and submission" do
          controller.should_receive(:respond_with).with(@session, @submission)
          put :update, @params
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      request.env['CONTENT_TYPE'] = 'application/json'

      @params = {
        :id => 123,
        :session_id => @session.id
      }
      @submission = Submission.new
      @submission.id = 123
      @submission.stub(:destroy)
      @session.stub(:submissions).and_return(double('submissions', :find => @submission))
      Session.stub(:find).and_return(@session)
    end
    describe "before filters" do
      before(:each) do
        controller.stub(:destroy)
        controller.stub(:load_member_if_signed_in)
        controller.stub(:find_session)
        controller.stub(:find_submission)
      end
      it "should have the load_member_if_signed_in before filter" do
        controller.should_receive(:load_member_if_signed_in)
        delete :destroy, @params
      end
      it "should have the find_session before filter" do
        controller.should_receive(:find_session)
        delete :destroy, @params
      end
      it "should have the find_submission before filter" do
        controller.should_receive(:find_submission)
        delete :destroy, @params
      end
    end
    describe "when logged in" do
      before(:each) do 
        login_user
      end
      it "should destroy the submission" do
        @submission.should_receive(:destroy)
        delete :destroy, @params
      end
      it "should redirect to the session" do
        delete :destroy, @params
        response.should redirect_to(@session)
      end
    end
  end
end
