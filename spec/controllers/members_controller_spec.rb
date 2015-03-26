require 'spec_helper'

describe MembersController do
  include LoginHelper

  let(:soundcloud_client_id) { '123' }
  let(:soundcloud_secret) { 'secret' }
  let(:soundcloud_app_client) { controller.soundcloud_app_client }

  before(:each) do
    allow(Sensori::Soundcloud).to receive(:client_id).and_return(soundcloud_client_id)
    allow(Sensori::Soundcloud).to receive(:secret).and_return(soundcloud_secret)
  end

  describe "#soundcloud_app_client" do
    it "should return a ::Soundcloud instance initialized with the Sensori client_id, secret, and redirect url" do
      soundcloud_app_client = controller.soundcloud_app_client
      soundcloud_app_client.should be_an_instance_of(::Soundcloud::Client)
      soundcloud_app_client.client_id.should == soundcloud_client_id
      soundcloud_app_client.client_secret.should == soundcloud_secret
      soundcloud_app_client.redirect_uri.should == members_soundcloud_connect_url
    end
  end

  describe "GET '/members/sign_in'" do    
    it "redirects to the Soundcloud authorizorization url" do
      get 'sign_in'
      expect(response).to redirect_to(soundcloud_app_client.authorize_url)
    end
  end

  describe "GET 'sign_out'" do
    let(:soundcloud_id) { 123 }
    let(:referer) { '/previous/url' }

    before(:each) do
      sign_in(soundcloud_id)
      request.env['HTTP_REFERER'] = referer
    end

    it "resets the session" do
      get 'sign_out'
      expect(session[:soundcloud_id]).to be_nil
    end

    it "redirects to the previous url with a flash notice" do
      get 'sign_out'
      expect(response).to redirect_to(referer)
    end

    it "sets a flash notice" do
      get 'sign_out'
      expect(flash[:notice]).not_to be_nil
    end
  end

  describe "GET 'soundcloud_connect'" do
    def make_request
      get 'soundcloud_connect', params
    end

    let(:member) { build(:member) }

    before(:each) do
      allow(Member).to receive(:sync_from_soundcloud).and_return(member)
    end

    context "when soundcloud code is present" do
      let(:code) { 'soundcayode' }
      let(:token) { 'soundtokez' }

      let(:exchange_response) { ::Soundcloud::HashResponseWrapper.new(access_token: token) }

      let(:params) do
        {
          code: code
        }
      end

      before(:each) do
        allow(soundcloud_app_client).to receive(:exchange_token).and_return(exchange_response)
      end

      it "syncs Member data from soundcloud" do
        expect(soundcloud_app_client).to receive(:exchange_token).with(code: code).and_return(exchange_response)
        expect(Member).to receive(:sync_from_soundcloud).with(token).and_return(member)
        make_request
      end

      context "when soundcloud Member sync is successful" do
        it "signs the user in" do
          make_request
          expect(session[:soundcloud_id]).to eq member.soundcloud_id
        end

        context 'when the Member already existed' do
          before do
            allow(member).to receive(:just_created?).and_return(false)
          end

          it "redirects to the root url" do
            make_request
            expect(response).to redirect_to(root_url)
          end

          it "sets flash data" do
            make_request
            expect(flash[:notice]).not_to be_nil
            expect(flash[:signed_up]).to be_false
          end
        end
        
        context 'when the Member was just created' do
          before do
            allow(member).to receive(:just_created?).and_return(true)
          end

          it "redirect to the root url" do
            make_request
            expect(response).to redirect_to(root_url)
          end

          it "sets flash data, including signed_up: true" do
            make_request
            expect(flash[:notice]).not_to be_nil
            expect(flash[:signed_up]).to be_true
          end
        end
      end

      context "when soundcloud Member sync fails" do
        let(:member) { build(:member, :email => nil, :soundcloud_id => nil) }
        
        it "does not sign the user in" do
          make_request
          expect(session[:soundcloud_id]).to be_nil
        end

        it "redirects to the root url with an error message" do
          make_request
          expect(response).to redirect_to(root_url)
        end

        it "sets a flash error message" do
          make_request
          expect(flash[:error]).not_to be_nil
          expect(flash[:signed_up]).to be_false
        end
      end
    end

    context "when soundcloud code is not present" do
      let(:params) { {} }

      it "does not sync member data from soundcloud" do
        expect(Member).not_to receive(:sync_from_soundcloud)
        make_request
      end

      it "redirects to the root url" do
        make_request
        expect(response).to redirect_to root_url
      end

      it "sets a flash error message" do
        make_request
        expect(flash[:error]).not_to be_nil
      end

      it "does not sign the user in" do
        make_request
        expect(session[:soundcloud_id]).to be_nil
      end
    end
  end

  describe "PUT 'update'" do
    def make_request
      put 'update', params
    end

    let(:email) { 'test@gmail.com' }

    let(:params) do
      {
        :id => member.id,
        :member => { 'email' => email },
        :format => 'json'
      }
    end

    let(:member) { create(:member) }

    context 'when the request is valid' do
      before do
        sign_in_as(member)
      end

      it "returns success" do
        make_request
        expect(response).to be_success
      end

      it "updates the member" do
        expect { 
          make_request 
        }.to change { member.reload.email }.to(email)
      end
    end

    context 'when the request is invalid' do    
      context 'when the member being updated is not the signed in member' do
        let(:other_member) { create(:member) }

        before do
          sign_in_as(other_member)
        end

        it "returns success" do
          make_request
          expect(response).to be_success
        end

        it "does not update the signed in member" do
          expect { 
            make_request 
          }.not_to change(member, :email)
        end

        it "does not update the other member" do
          expect { 
            make_request 
          }.not_to change(other_member, :email)
        end
      end

      context 'when not currently signed in' do
        it "returns success" do
          make_request
          response.should be_success
        end

        it "does not update the member" do
          expect { 
            make_request 
          }.not_to change(member, :email)
        end
      end

      context 'when parameters are invalid' do
        before do
          sign_in_as(member)
        end

        let(:params) do
          {
            :id => member.id,
            :member => { 'image_url' => nil },
            :format => 'json'
          }
        end

        it "returns an error" do
          make_request
          expect(response.status).to eq 422
        end

        it "does not update the member" do
          expect { 
            make_request 
          }.not_to change(member, :email)
        end
      end
    end
  end

  describe "GET 'show'" do
    def make_request
      get 'show', params
    end

    let(:params) { { :id => member.id } }

    let(:member) { create(:member) }
    let!(:track_1) { create(:track, :member => member, :posted_at => 2.days.ago) }
    let!(:track_2) { create(:track, :member => member, :posted_at => 1.day.ago)  }

    it "should return http success" do
      make_request
      expect(response).to be_success
    end
    it "renders the show template" do
      make_request
      expect(response).to render_template('members/show')
    end
    it "finds and assigns the member" do
      make_request
      expect(assigns[:member]).to eq member
    end
    it "finds and assigns the member's latest tracks" do
      make_request
      expect(assigns[:tracks]).to eq([track_2, track_1])
    end
  end
end