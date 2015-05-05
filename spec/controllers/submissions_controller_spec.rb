require 'spec_helper'

describe SubmissionsController do
  include LoginHelper

  let(:member) { create(:member) }
  let!(:session_model) { create(:session) }

  shared_examples_for "finding the associated session" do
    it "finds and assigns @session" do
      make_request
      expect(assigns[:session]).to eq session_model
    end
  end

  shared_examples_for "finding the submission" do
    it "finds and assigns @submission" do
      make_request
      expect(:submission).to eq submission
    end
  end

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:params) do
      {
        format: 'json',
        session_id: session_model.id,
        submission: submission_params
      }
    end

    let(:submission_params) do
      {
        title: "My Beat",
        attachment_url: "http://s3.amazon.com/beat.mp3"
      }
    end

    context "when signed in" do
      before do 
        sign_in_as(member)
        allow(controller).to receive(:respond_with).and_call_original
      end

      it_should_behave_like 'finding the associated session'

      it "removes :session, :session_id, :member, and :member_id from params[:submission] without changing other params" do
        submission_params.merge!({
          session: 1,
          session_id: 2,
          member: 3,
          member_id: 4
        })
        params[:other_stuff] = 'more data'

        make_request

        expect(controller.params[:submission]).to eq({
          'title' => 'My Beat',
          'attachment_url' => "http://s3.amazon.com/beat.mp3"
        })
        expect(controller.params[:other_stuff]).to eq 'more data'
      end

      context 'when the submission is valid' do
        let(:created_submission) { Submission.last }

        it "creates a submission for the member and session" do
          expect { 
            make_request 
          }.to change { Submission.count }.by(1)

          expect(created_submission.title).to eq submission_params[:title]
          expect(created_submission.attachment_url).to eq submission_params[:attachment_url]
          expect(created_submission.session).to eq session_model
          expect(created_submission.member).to eq member
        end

        it "responds with 201 status" do
          make_request
          expect(response.status).to eq 201
        end

        it "responds with the session and submission" do
          make_request
          expect(controller).to have_received(:respond_with).with(session_model, created_submission)
        end
      end

      context "when the submission is invalid" do
        before do
          submission_params[:title] = ''
        end

        it "does not create a submission" do
          expect {
            make_request
          }.not_to change { Submission.count }
        end

        it "responds with the session and submission" do
          make_request
          expect(controller).to have_received(:respond_with).with(session_model, an_instance_of(Submission))
        end

        it "responds with 422 status" do
          make_request
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    let!(:submission) { create(:submission, session: session_model, member: member, updated_at: 1.day.ago) }

    let(:params) do
      {
        id: submission.id,
        session_id: session_model.id,
        submission: submission_params,
        format: 'json'
      }
    end

    let(:submission_params) do
      {
        title: "My Beat",
        attachment_url: "http://s3.amazon.com/beat.mp3"
      }
    end

    it_should_behave_like 'finding the associated session'

    context "when signed in" do
      before do 
        sign_in_as(member)
        allow(controller).to receive(:respond_with).and_call_original
      end

      it_should_behave_like 'finding the associated session'

      context 'when the submission is valid' do
        it "updates the submission" do
          expect { 
            make_request 
          }.to change { submission.reload.updated_at }

          submission.reload

          expect(submission.title).to eq submission_params[:title]
          expect(submission.attachment_url).to eq submission_params[:attachment_url]
        end

        it "responds with 200 status" do
          make_request
          expect(response.status).to eq 200
        end

        it "responds with the session and submission" do
          make_request
          expect(controller).to have_received(:respond_with).with(session_model, submission.reload)
        end
      end

      context "when the submission is invalid" do
        before do
          submission_params[:title] = ' '
        end

        it "does not update the submission" do
          expect {
            make_request
          }.not_to change { submission.reload.updated_at }
        end

        it "responds with the session and submission" do
          make_request
          expect(controller).to have_received(:respond_with).with(session_model, submission)
        end

        it "responds with 422 status" do
          make_request
          expect(response.status).to eq 422
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    def make_request
      delete 'destroy', params
    end

    let!(:submission) { create(:submission, member: member, session: session_model) }

    let(:params) do
      {
        id: submission.id,
        session_id: session_model.id
      }
    end
    
    context "when signed in" do
      before(:each) do 
        sign_in_as(member)
      end

      it "destroys the submission" do
        expect {
          make_request
        }.to change { Submission.count }.by(-1)

        expect(Submission.exists?(submission.id)).to be_false
      end

      it "redirects to the session" do
        make_request
        expect(response).to redirect_to(session_model)
      end
    end
  end
end
