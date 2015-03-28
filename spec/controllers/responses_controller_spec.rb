require 'spec_helper'

describe ResponsesController do
  include LoginHelper

  describe "POST 'create'" do
    def make_request
      post 'create', params
    end

    let(:member) { create(:member) }

    let(:discussion) { create(:discussion) }

    let(:params) do
      {
        response: {
          discussion_id: discussion.id,
          body: 'body'
        },
        format: 'json'
      }
    end

    it_should_behave_like 'an action that requires a signed in member'

    context 'when signed in' do
      before do
        sign_in_as(member)
      end

      let(:created_response) { discussion.responses.last }

      it "creates a response" do
        expect { 
          make_request 
        }.to change { discussion.responses.count }.by(1)

        expect(created_response.body).to eq params[:response][:body]
      end
      
      it "assigns the response" do
        make_request
        expect(assigns[:response]).to eq created_response
      end

      it "responds with 201 created" do
        make_request
        expect(response.status).to eq 201
      end

      context 'when there are errors' do
        before do
          params[:response][:body] = nil
        end

        it "does not create a response" do
          expect {
            make_request
          }.not_to change { discussion.responses.count }
        end

        it "responds with 422" do
          make_request
          expect(response.status).to eq 422
        end
      end
    end
  end
end
